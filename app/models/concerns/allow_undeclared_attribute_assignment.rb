module AllowUndeclaredAttributeAssignment
  extend ActiveSupport::Concern

  def initialize(attributes={})
    sanitization = attributes.select do |k, v|
      self.respond_to? "#{k}="
    end
    super sanitization
  end

end
