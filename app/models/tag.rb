class Tag < Base
  attr_accessor :action, :id, :name, :gamaitems

  def initialize attributes
    attributes.each { |k,v| send("#{k}=", v)}
  end
end