class CartsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:success]
  before_action :get_coupons#, only: [:step1, :checkout, :remove_coupon]
  before_action :check_cart, only: [:step1, :step2]

  def show
  end

  # [step1] == POST => [process_step1] == REDIRECT =>  [step2] == POST => [checkout] == REDIRECT => [success]
  def step1
    
    if !@cart.convenience_store_available? && @cart.delivery_method == Cart::DELIVERY_METHODS[:convenience_store]
      @cart.delivery_method = Cart::DELIVERY_METHODS[:cod]
    end
    reasons = @cart.why_cannot_checkout?
    if !reasons.empty?
      redirect_back(fallback_location: root_path,
                    alert: "很抱歉，某些商品無法結帳，要請您移除: #{reasons.join(",")}")
    end
  end

  def update_delivery_method
    @cart.delivery_method = params[:delivery_method].to_i
    if !@cart.convenience_store_available? && @cart.delivery_method == Cart::DELIVERY_METHODS[:convenience_store]
      @cart.delivery_method = Cart::DELIVERY_METHODS[:cod]
    end
  end

  def process_step1
    session[:checkout_step1] = order_params
    redirect_to carts_checkout_2_path
  end

  def step2
    if @cart.delivery_method == Cart::DELIVERY_METHODS[:convenience_store] && !@cart.convenience_store_available?
      redirect_to carts_checkout_path, alert: '您購物車內的商品不適用超商取貨，請選取其他的運送方式'
    end

    # keeped data from previous submission
    @buf = session[:checkout_step2].try(:symbolize_keys) || {}
    # give it some default
    @buf[:invoice_types] ||= '0'
    @buf[:foundation_id] ||= '876'
    @buf[:carrier_type] ||= '0'
  end

  def checkout
    begin
      # keep the data
      session[:checkout_step2] = order_params

      args = order_params.merge(session[:checkout_step1]).merge(session[:order_utm])
      if signed_in?
        args['is_mem'] = '1'
        args['auth_token'] = current_member.auth_token
      else
        args['is_mem'] = '0'
        args.delete('auth_token')
      end

      # ichannel
      if cookies[:gid].present?
        args['source'] = 'ichannel'
        args['medium'] = 'paid'
        args['term'] = "gid"
        args['content'] = cookies[:gid]
      end

      args = args.to_h

      args[:itemidlist] = @cart.line_items.reduce([]) do |all, current|
        all.push(*[current.gamaitem_id]*current.quantity)
      end.join(',')

      args[:totalprice] = @cart.totalprice.to_i

      args[:shipping] = @cart.shipping_fee.to_i

      args[:mcid] = @cart.coupon.mcid if @cart.coupon.present?
      if @browser.device.mobile? || @browser.device.mobile?
        args[:app_version] = 'Mobile_Web_V_1.0.0'
        args[:os_type] = 4
      else
        args[:app_version] = 'Desktop_Web_V_1.0.0'
        args[:os_type] = 3
      end

      # forward to gamadian api
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['create_order']}")
      # uri = URI("https://api.gamadian.com/api/v9/orders.json")
      uri.query = URI.encode_www_form(args)
      res = Net::HTTP.post_form(uri, {})

      case res
      when Net::HTTPOK
        unless signed_in?
          member = Member.login(params[:email], params[:password])
          if member.present?
            session[:member_json] = member.to_json
          end
        end

        # handle pay2go
        if args[:deliverymethod] == '3'
          # XXX double json encoded...
          @pay2go_args = JSON.parse(JSON.parse(res.body)["data"])
          @pay2go_args['ReturnURL'] = carts_checkout_success_url
          # redirect_to carts_checkout_pay2go_path
          render "pay2go"
        else
          redirect_to carts_checkout_success_path
        end
        @cart.mark_as_done
      else
        # show error message
        msg = JSON.parse(res.body)["message"]
        redirect_to carts_checkout_2_path, alert: msg
      end
    rescue Exception => e
      logger.warn('---------------------------')
      logger.warn(args) if args.present?
      logger.warn(uri) if uri.present?
      logger.warn(JSON.parse(res.body)) if res.present?
      logger.warn(e.message)
      logger.warn('---------------------------')
      NewRelic::Agent.notice_error(e)
      redirect_to carts_checkout_2_path, alert: "未知錯誤，請聯絡客服"
    end
  end

  def success
    if !signed_in?
      redirect_to members_signin_path
    else
      @order = current_member.orders.last
      @subtotal = @order.gamaitems.map { |h| h['price'].to_i * h['gamaitcount'] }.sum
    end
  end

  def pay2go
  end

  def put
    @quantity = (params[:quantity] || 1).to_i
    @cart.put Gamaitem.find_by_id(params[:id]), @quantity, current_member
    @item = @cart.find_line_item_by_id(params[:id])
  end

  def take
    @quantity = (params[:quantity] || 1).to_i
    @cart.take Gamaitem.new(id: params[:id]), @quantity, current_member
    @item = @cart.find_line_item_by_id(params[:id])
  end

  def apply_coupon
    begin
      # try without authenticated
      coupon = Coupon.find_by_code(params[:promocode])
      if coupon.nil?
        if signed_in?
          coupon = Coupon.find_by_code_with_authenticated(params[:promocode],
                                                          current_member.email,
                                                          current_member.auth_token)
        end
      end

      if coupon.present?
        _, err = @cart.try_coupon(coupon)
        if err.blank?
          @cart.apply_coupon(coupon)
        else
          flash.alert = err
        end
      else
        flash.alert = "Invalid coupon code"
      end
    rescue Exception => e
      logger.warn "Invalid coupon application: #{e.message}. Stacktace: #{e.backtrace.join("\n")}"
      flash.alert = "Invalid coupon code"
    end
  end

  def remove_coupon
    @cart.remove_coupon()
  end

  private
  def order_params
    params.permit(
      :email,
      :password,
      :device_id,
      :name,
      :phone,
      :city,
      :area,
      :postcode,
      :address,
      :location,
      :promocode,
      :totalprice,
      :shipping,
      :deliverymethod,
      :conveniencestoreid,
      :itemidlist,
      :isuser,
      :origin,
      :cardnumber,
      :expiresyear,
      :expiresmonth,
      :securitycode,
      :mcid,
      :app_version,
      :invoice_types,
      :carrier_type,
      :carrier_num,
      :foundation_id,
      :invoice_delivery_address,
      :invoice_buyer_ubn,
      :invoice_buyer_title,
      :os_type,
      :auth_token,
      :conveniencedstorename)
  end

  def check_cart
    if @cart.line_items.blank?
      redirect_to root_path, alert: "購物車沒有商品無法結帳，請至商品頁繼續挑選"
    end
  end

  def get_coupons
    @coupons = signed_in? ? current_member.coupons : Array.new
  end

end
