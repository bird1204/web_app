class Coupon < Base
  include ActiveModel::Serializers::JSON

  attr_accessor :id,
                :appVersion,
                :app_version,
                :code,
                :condition,
                :coupon_type,
                :created_at,
                :description,
                :discount,
                :endDate,
                :expiration_date,
                :is_show,
                :li_description,
                :li_item_tag,
                :li_price,
                :li_quantity,
                :limitDescription,
                :long_name,
                :mcid,
                :nameL,
                :nameS,
                :price,
                :quantity,
                :short_name,
                :tag,
                :type,
                :updated_at,
                :useDate

  def attributes
    [:id,
     :app_version,
     :code,
     :condition,
     :coupon_type,
     :created_at,
     :discount,
     :expiration_date,
     :is_show,
     :li_item_tag,
     :li_price,
     :li_quantity,
     :mcid,
     :price,
     :quantity,
     :short_name,
     :tag,
     :type,
     :updated_at,
     ].map do |key|
       [key, nil]
     end.to_h
  end

  class << self
    def find_by_code(code)
      find_by_code_with_authenticated(code)
    end

    def find_by_code_with_authenticated(code, email='', token='')
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['coupons']}")
      # uri = URI('https://api.gamadian.com/api/v9/coupons')
      uri.query = URI.encode_www_form({
        email: email,
        auth_token: token,
        code: code,
      })

      rsp = JSON.parse Net::HTTP.get(uri)
      if rsp['status'] == 1
        Coupon.new(rsp['coupon'].merge({mcid: rsp['mcid']}))
      else
        nil
      end
    end
  end
end
