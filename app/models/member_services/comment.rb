class Comment
  ATTRS =[
    :reason, 
    :head, 
    :message, 
    :name, 
    :place, 
    :price, 
    :question, 
    :city_area, 
    :city, 
    :address, 
    :phone, 
    :content,
    :invoice,
    :head,
  ]
  
  attr_accessor(*ATTRS)

  def attributes
    ATTRS.map {|key| [key, nil]}.to_h
  end

  def attributes=(hash)
    hash.each do |key, v|
      send("#{key}=", v)
    end
  end

  def invoice
    @invoice ||= Invoice.new
  end

  def invoice= attributes
    @invoice = Invoice.new attributes
  end

  def head
    @head ||= Head.new
  end

  def head= attributes
    @head = Head.new attributes
  end
end