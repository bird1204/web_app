class Member < Base
  include ActiveModel::Serializers::JSON
  ATTRS =[ :address,
           :auth_token,
           :city,
           :city_area,
           :email,
           :name,
           :phone_number,
           :postcode,
           :provider,
           :user_id,
           :facebook_token,
           :gender,
           :birthday, 
           :complete_registration,
         ]

  attr_accessor(*ATTRS)

  WEB_OS_TYPE = 3
  GENDER = [ nil, :"男", :"女"]

  class << self
    def invalidate_fb_user(email, provider='direct', user_id=nil, facebook_token=nil)
      # get member with token
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['invalidate_fb_user']}")
      uri.query = URI.encode_www_form({
                                        email: email,
                                        device_id: SecureRandom.uuid,
                                        provider: provider,
                                        user_id: user_id,
                                        facebook_token: facebook_token

      })
      res = Net::HTTP.post_form(uri, {})
      JSON.parse(res.body)
    end

    def login(email, password, provider='direct', user_id=nil, facebook_token=nil)
      # get member with token
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['sign_in']}")
      uri.query = URI.encode_www_form({
                                        email: email,
                                        password: password,
                                        device_id: SecureRandom.uuid,
                                        provider: provider,
                                        user_id: user_id,
                                        facebook_token: facebook_token

      })
      res = Net::HTTP.post_form(uri, {})
      if JSON.parse(res.body)['message'].present?
        nil
      else
        Member.new(JSON.parse(res.body).merge!(provider: provider, user_id: user_id, facebook_token: facebook_token))
      end
    end

    def create_by_email_password(email, password, provider='direct', user_id=nil, facebook_token=nil)
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['resgistration']}")
      uri.query = URI.encode_www_form({
                                        email: email,
                                        password: password,
                                        device_id: SecureRandom.uuid,
                                        provider: provider,
                                        user_id: user_id,
                                        facebook_token: facebook_token
      })
      res = Net::HTTP.post_form(uri, {})
      begin
        message = JSON.parse(res.body)['message']
        if message.present? && message == 'success'
          member = Member.login(email, password)
          member.complete_registration = true
          [member, ""]
        else
          [nil, message]
        end
      rescue Exception => e
        [nil, e.message]
      end
    end
  end

  def attributes
    ATTRS.map {|key| [key, nil]}.to_h
  end

  def attributes=(hash)
    hash.each do |key, v|
      send("#{key}=", v)
    end
  end

  def update_attributes! attributes
    uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['update_member_info']}")
    uri.query = URI.encode_www_form(
      attributes.merge!(
        email: email,
        provider: provider,
        user_id: user_id,
        facebook_token: facebook_token,
        device_id: SecureRandom.uuid,
        auth_token: auth_token
      )
    )

    http = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https')
    request = Net::HTTP::Put.new uri
    res = http.request request

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      if JSON.parse(res.body)['message'] == 'success'
        self.attributes = attributes.select{|key| key if ATTRS.include?(key)}
        self.email = attributes[:new_email] if attributes[:new_email].present?
        return self
      else
        fail JSON.parse(res.body)['message']
      end
    else
      res.value
    end
  end

  def orders
    uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['orders']}")
    # uri = URI("https://api.gamadian.com/api/v9/orders/order_info.json")
    uri.query = URI.encode_www_form({
                                      email: email,
                                      auth_token: auth_token,
    })
    rsp = JSON.parse Net::HTTP.get(uri)

    rsp.map do |data|
      Order.new data
    end
  end

  def find_order_by_id(id)
    orders.find {|order| order.ordernumber.to_i == id.to_i}
  end

  def last_order
    current_member.orders.last
  end

  def coupons
    uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['member_couponships']}")
    # uri = URI("https://api.gamadian.com/api/v9/coupons/membercoupon_info")
    uri.query = URI.encode_www_form({
                                      email: email,
                                      auth_token: auth_token,
    })
    rsp = JSON.parse Net::HTTP.get(uri)

    rsp.map do |data|
      Coupon.new data
    end
  end

  def coupon(code)
    uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['coupons']}")
    # uri = URI('https://api.gamadian.com/api/v9/coupons')
    uri.query = URI.encode_www_form({
                                      email: email,
                                      auth_token: auth_token,
                                      code: code,
    })
    rsp = JSON.parse Net::HTTP.get(uri)
    if rsp['status'] == 1
      Coupon.new(rsp['coupon'].merge({mcid: rsp['mcid']}))
    else
      nil
    end

  end

  def name
    if @name.blank?
      @email.split('@').first
    else
      @name
    end
  end

  def origin= hash
    Origin.set(
      hash,
      { email: email, auth_token: auth_token, os_type: WEB_OS_TYPE }
    )
  end

  #建立貼近rails慣例的method
  #可以用：current_member.member_services
  def member_services
    return MemberService.all self
  end
end
