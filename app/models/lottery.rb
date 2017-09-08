class Lottery < Base

  attr_accessor :value, :message

 # Lottery.draw(phone_num: '0922300906')
  class << self
    def draw params={}
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['lottery']}")
      res = Net::HTTP.post_form(uri, params)
      rsp = JSON.parse(res.body)
      Lottery.new rsp
    end
  end

end
