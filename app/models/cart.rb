class Cart < Base
  include ActiveModel::Serializers::JSON

  DELIVERY_METHODS = {
    convenience_store: 1,
    cod: 2, # cash on delivery
    credit_card: 3,
  }

  attr_accessor :raw_line_items, :coupon, :done, :delivery_method, :synced

  def attributes
    {
      'raw_line_items' => nil,
      'coupon' => nil,
      'done' => false,
      'delivery_method' => nil,
      'synced' => false
    }
  end

  def attributes=(hash)
    @raw_line_items = hash['raw_line_items']
    @coupon = nil
    @coupon = Coupon.new hash['coupon'] if hash['coupon'].present?
    @done = hash['done'] || false
    @delivery_method = hash['delivery_method'].try(:to_i) || 1
    @synced = hash['synced'] || false
  end

  def mark_as_unsynced!
    @synced = false
  end

  def mark_as_synced!
    @synced = true
  end

  def mark_as_done
    @done = true
  end

  def line_items
    @raw_line_items ||= {}
    @raw_line_items.map do |id, quantity|
      LineItem.new(gamaitem_id: id.to_i, quantity: quantity)
    end.select {|line_item| line_item.quantity > 0}
  end

  def find_line_item_by_id(id)
    LineItem.new(gamaitem_id: id.to_s, quantity: @raw_line_items[id])
  end

  def sync(gamaitems, member=nil)
    gamaitems.each do |gamaitem, quantity|
      gamaitem_id = "#{gamaitem.id}"
      limitation = gamaitem.maximum_purchase_quantity.present? ? gamaitem.maximum_purchase_quantity : conditions[:maximum_purchase_quantity]
      @raw_line_items ||= {}
      @raw_line_items[gamaitem_id] ||= 0
      if @raw_line_items[gamaitem_id] <= limitation
        @raw_line_items[gamaitem_id] = [quantity, gamaitem.sku].min
      end
    end
    if member.present?
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['gamaitem_memberships']}")
      uri.query = URI.encode_www_form({
                                        email: member.email,
                                        auth_token: member.auth_token,
                                        itemnumlist: @raw_line_items.collect{|id, quantity| "#{id}.#{quantity}"}.join(',')
      })
      line_item_hash = Hash.new
      JSON.parse(Net::HTTP.post_form(uri, {}).body).each { |rsp| line_item_hash = line_item_hash.merge(:"#{rsp['id']}" => rsp['quantity'].to_i) }
      raw_line_items = line_item_hash
    end
    cart_update
  end

  def put(gamaitem, quantity=1, member=nil)
    limitation = gamaitem.maximum_purchase_quantity.present? ? gamaitem.maximum_purchase_quantity : conditions[:maximum_purchase_quantity]
    gamaitem_id = "#{gamaitem.id}"
    @raw_line_items = @raw_line_items.present? ? @raw_line_items : Hash.new
    @raw_line_items[gamaitem_id] ||= 0
    if @raw_line_items[gamaitem_id] + quantity <= limitation
      @raw_line_items[gamaitem_id] += [quantity, gamaitem.sku].min
      if member.present?
        # get member with token
        uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['gamaitem_memberships']}")
        uri.query = URI.encode_www_form({
                                          email: member.email,
                                          auth_token: member.auth_token,
                                          itemnumlist: "#{gamaitem_id}.#{@raw_line_items[gamaitem_id]}"
        })
        line_item_hash = Hash.new
        JSON.parse(Net::HTTP.post_form(uri, {}).body).each { |rsp| line_item_hash = line_item_hash.merge(:"#{rsp['id']}" => rsp['quantity'].to_i) }
        raw_line_items = line_item_hash
      end
    end


    cart_update
  end

  def take(gamaitem, quantity=1, member=nil)
    @raw_line_items ||= {}
    if @raw_line_items[gamaitem.id].present?
      @raw_line_items[gamaitem.id] -= quantity
      if member.present?
        # get member with token
        uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['gamaitem_memberships']}")
        uri.query = URI.encode_www_form({
                                          email: member.email,
                                          auth_token: member.auth_token,
                                          itemnumlist: "#{gamaitem.id}.#{@raw_line_items[gamaitem.id]}"
        })
        line_item_hash = Hash.new
        JSON.parse(Net::HTTP.post_form(uri, {}).body).each { |rsp| line_item_hash = line_item_hash.merge(:"#{rsp['id']}" => rsp['quantity'].to_i) }
        raw_line_items = line_item_hash
      end
    end
    cart_update
  end

  def take_all_of_a(gamaitem)
    @raw_line_items[gamaitem.id].tap do |quantity|
      if quantity.present? && quantity > 0
        @raw_line_items[gamaitem.id] = 0
      end
    end
    cart_update
  end

  def total_quantity
    line_items.map {|li| li.quantity}.sum
  end

  def total_item_quantity
    line_items.size()
  end

  def shipping_fee
    if total_amount >= free_ship_threshold
      0
    else
      case delivery_method
      when DELIVERY_METHODS[:convenience_store]
        conditions[:cvs_pickup_payment]
      when DELIVERY_METHODS[:cod]
        conditions[:home_delivery_payment]
      when DELIVERY_METHODS[:credit_card]
        conditions[:home_delivery_creditcard]
      end
    end
  end

  def free_ship_threshold
    conditions[:free_shipping_expenses]
  end

  def total_amount
    if line_items.size() < 1
      return 0
    end

    line_items.map {|li| li.gamaitem.price * li.quantity}.sum
  end

  def satisfy_item_limitation(cipher, type)
    if type.to_i == 9
      true
    else
      method = type.to_i == 1 ? :all? : :any?
      cipher.split(',').map {|li| li.split('-')}.send(method) do |quantity, gamaitem_id|
        @raw_line_items.key?(gamaitem_id) && @raw_line_items[gamaitem_id].to_i >= quantity.to_i
      end
    end
  end

  def coupon_value
    if !@coupon.nil?
      try_coupon(@coupon).first
    else
      0
    end
  end

  # it will update the coupon if inputed valid coupon code
  def apply_coupon(coupon)
    value, err = try_coupon(coupon)
    @coupon = coupon if value >= 0
    return value, err
  end

  def remove_coupon
    @coupon = nil
  end

  def try_coupon(coupon)
    if total_amount < coupon.li_price.to_i
      return 0, "請確認優惠碼使用最低金額"
    end

    # "1-1236,2-1410,3-1938",
    if !satisfy_item_limitation(coupon.li_item_tag, coupon.condition)
      return 0, "優惠碼不符合訂單產品使用限制"
    end

    value = if coupon.coupon_type == '1'
      total_amount * (1.0-(coupon.discount.to_f))
    elsif coupon.coupon_type == '2'
      coupon.discount.to_i
    end

    return value.floor, ""
  end

  # payment amount
  def totalprice
    total_amount + shipping_fee - (@coupon.present? ? try_coupon(@coupon)[0] : 0)
  end

  def convenience_store_available?
    weight? && end_edge? && all_edge? && volume?
  end

  def conditions
    Rails.cache.fetch("WEB/cart_conditions", expires_in: 1.hour) do
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['adjusted_figures']}")
      # uri = URI("https://api.gamadian.com/api/v9/adjusted_figures.json")
      rsp = JSON.parse Net::HTTP.get(uri)
      rsp.symbolize_keys.slice(
        #
        :free_shipping_expenses,
        #
        :cvs_maximum_volume,
        :cvs_maximum_volume_V2,
        :cvs_maximum_weight,
        :cvs_maximum_ledge,
        :cvs_maximum_sedge,
        :cvs_maximum_eedge,
        :cvs_maximum_total_eedge,
        :maximum_purchase_quantity,
        #
        :cvs_pickup_payment,
        :home_delivery_payment,
        :home_delivery_creditcard,
      ).map do |k, v|
        [k, v.to_f]
      end.to_h
    end
  end

  def why_cannot_checkout?
    uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['checking_gamaitem_memberships']}")
    # uri = URI('https://api.gamadian.com/api/v10/gamaitem_memberships/checking')
    uri.query = URI.encode_www_form({
                                      id: line_items.map {|line_item| "#{line_item.gamaitem.id}.#{line_item.quantity}"}.join(',')
    })
    rsp = JSON.parse Net::HTTP.get(uri)
    # rsp = {'gamaitems' => [{"id" => 1774,"sku"=>"0","price"=>179,"is_buy"=>true},{"id"=>2207,"sku"=>"330","price"=>25,"is_buy"=>false}]}
    # collect reasons
    rsp['gamaitems'].map do |gamaitem_status|
      line_item = find_line_item_by_id(gamaitem_status['id'])
      line_item.quantity = @raw_line_items["#{line_item.gamaitem_id}"]
      if !line_item.nil?
        message = {
          sku: "#{line_item.gamaitem.name} 庫存不足",
          price: "#{line_item.gamaitem.name} 價錢異動",
          is_buy: "#{line_item.gamaitem.name} 無法購買",
          maximum_purchase_quantity: "#{line_item.gamaitem.name} 超出限購數量(#{gamaitem_status['maximum_purchase_quantity']})"
        }
        {
          sku: gamaitem_status['sku'].to_i <= 0,
          price: gamaitem_status['price'] != line_item.gamaitem.price,
          is_buy: !gamaitem_status['is_buy'],
          maximum_purchase_quantity: line_item.quantity > gamaitem_status['maximum_purchase_quantity']
        }.map do |k, v|
          if v
            message[k]
          end
        end.compact
      end
    end.flatten.compact
  end

  private
  def weight?
    # 三樣商品總重要小於cvs_maximum_weight
    line_items.map do |line_item|
      line_item.gamaitem.weight * line_item.quantity
    end.sum <= conditions[:cvs_maximum_weight]
  end

  def end_edge?
    # 三樣商品的end_edge總和要小於cvs_maximum_total
    line_items.map do |line_item|
      line_item.gamaitem.end_edge * line_item.quantity
    end.sum <= conditions[:cvs_maximum_total_eedge]
  end

  def all_edge?
    # 各商品的則要符合最長邊限制(cvs_maximum_ledge)  次長邊限制(cvs_maximum_sedge) 最短編限制(cvs_maximum_eedge)
    line_items.map(&:gamaitem).all? do |gamaitem|
      gamaitem.longest_edge <= conditions[:cvs_maximum_ledge] &&
        gamaitem.second_edge <= conditions[:cvs_maximum_sedge] &&
        gamaitem.end_edge <= conditions[:cvs_maximum_eedge]
    end
  end

  def volume?
    # 體積限制則是所有商品三邊相乘的總和
    line_items.map do |line_item|
      [
        :longest_edge,
        :second_edge,
        :end_edge
      ].map {|name| line_item.gamaitem.send(name)}.reduce(1, :*) * line_item.quantity
    end.sum <= conditions[:cvs_maximum_volume_V2]
  end

  def cart_update
    if @coupon.present?
      val, err = try_coupon(@coupon)
      if !err.blank?
        remove_coupon
      end
    end

    if !convenience_store_available? && self.delivery_method == DELIVERY_METHODS[:convenience_store]
      delivery_method = DELIVERY_METHODS[:cod]
    end
  end

end
