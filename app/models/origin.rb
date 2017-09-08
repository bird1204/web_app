class Origin < Base
  attr_accessor :source, :medium, :campaign, :term, :content

  class << self
    def set utm_sources, valid_params
      Origin.new(utm_sources).update!(valid_params)
    end
  end

  def initialize attributes
    attributes.each { |k,v| send("#{k}=", v)}
  end

  def attributes
    { source: source, medium: medium, campaign: campaign, term: term, content: content }
  end

  def update! params
    uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['origin']}")
    uri.query = URI.encode_www_form(params.merge!(attributes))
    res = Net::HTTP.post_form(uri, {})
    case res
    when Net::HTTPUnauthorized
      res.body['message']
    when Net::HTTPOK
      res.body['message']
    end
  end
end
