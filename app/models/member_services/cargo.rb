class Cargo < Base
  
  ATTRS = [
    :name, 
    :city,
    :city_area,
    :address,
    :phone
  ]

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
