class Area < Base
  attr_accessor :id, :name, :gamaitems

  def initialize attributes
    attributes.each { |k,v| send("#{k}=", v)}
  end
end