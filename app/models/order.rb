class Order < Base
  include ActiveModel::Serializers::JSON
  ATTRS = [:address,
        :coupon_code,
        :coupon_discount,
        :coupon_type,
        :created_at,
        :delivery_no,
        :deliverymethod,
        :discount,
        :gamaitems,
        :invoice,
        :name,
        :ordernumber,
        :phone,
        :shipping,
        :situation_of_cargo_id,
        :st_addr,
        :st_name,
        :totalprice, 
        :subtotal]

  attr_accessor(*ATTRS)

  def subtotal
    @gamaitems.map { |item| item['price'].to_i * item['gamaitcount'] }.sum
  end

  def to_ga_enhanced_ec_data
    {
      ecommerce: {
        purchase: {
          actionField: {
            id: ordernumber.to_s,
            revenue: totalprice.to_s,
            tax: '0',
            shipping: shipping.to_s,
            coupon: coupon_code,
          },
          'products': @gamaitems.map do |item|
            {
              id: item['gamaid'],
              name: item['gamaitname'],
              quantity: item['gamaitcount'].to_i,
              price: item['price'].to_i,
            }
          end
        }
      }
    }
  end

  def attributes
    ATTRS.map {|key| [key, nil]}.to_h
  end

  def attributes=(hash)
    hash.each do |key, v|
      send("#{key}=", v)
    end
  end


end
