class Invoice
  ATTRS =[:type,:carrier_type,:carrier_num,:buyer_ubn,:city_area,:city,:address,:foundation_id]
  attr_accessor(*ATTRS)

  def attributes
    ATTRS.map { |key| [key, nil] }.to_h
  end

  def attributes=(hash)
    hash.each do |key, v|
      send("#{key}=", v)
    end
  end
end