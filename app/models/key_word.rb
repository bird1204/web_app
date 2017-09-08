class KeyWord < Base
  attr_accessor :string
  class << self
    def get_list
      Rails.cache.fetch("WEB/hot_keywords/", expires_in: 1.hours) do
        uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['hot_keywords']}")
        res = Net::HTTP.get_response(uri)
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          JSON.parse(res.body).map do |keyword|
            KeyWord.new string: keyword
          end
        else
          fail res.body
        end
      end
    end
  end
end
