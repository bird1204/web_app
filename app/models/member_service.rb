class MemberService < Base
  include ActiveModel::Serializers::JSON
  # ATTRS 用來記錄API回傳的資料
  ATTRS =[
    :images_url,
    :comment,
    :member_content,
    :member_service_messages_attributes,
    :member_email,
    :id,
    :member_displayed,
    :status,
    :order_id,
    :member_content,
    :member_content_head,
    :replies,
    :created_at,
    :updated_at,
    :title,
    :member,
    :contact,
    :contact_method,
    :question_id,
    :message,
  ]
  attr_accessor(*ATTRS)

  INVOICE_TYPE = [ :"電子發票", :"三聯式紙本發票"]
  INVOICE_CARRIER_TYPE = [ :"手機條碼載具",:"自然人憑證載具",:"甘仔店會員載具"]

  QUESTION_IDS = [
    [1, "改聯絡人姓名、電話、地址、電子發票"], 
    [2, "更改付款方式"], 
    [3, "增減商品數量、換商品"], 
    [4, "尚未收到貨想取消訂單或商品"], 
    [5, "已收到貨想取消訂單或商品"], 
    [6, "已收到貨想取消訂單或商品"], 
    [7, "商品多寄"], 
    [8, "商品少寄"], 
    [9, "商品破損、變質"], 
    [10, "過久未到貨"], 
    [11, "我要的商品什麼時候補貨"], 
    [12, "我覺得有些商品太貴了"], 
    [13, "其他商品問題"], 
    [14, "商品建議"], 
    [15, "服務建議"], 
    [16, "App功能建議"], 
    [17, "商品合作"], 
    [18, "通路合作"], 
    [19, "其他合作"], 
    [20, "撥打電話 (星期一到五，10:00 ~ 18:00)"], 
    [21, "Line訊息 (星期一到日，9:00 ~ 21:00)"], 
    [22, "寄送Email (星期一到日，21:00 ~ 9:00)"]
  ]

  class << self
    def create! attributes
      #建立客服需求
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['member_service']}")
      hash = hash_regenerate! attributes
      # p '---------------'
      # p hash
      # p '---------------'
      # uri.query = URI.encode_www_form(hash)
      p '---------------'
      p hash
      p '---------------'
      # fail 'fwejifjwo'
      res = Net::HTTP.post_form(uri, hash) 
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        res_json = JSON.parse(res.body)
        if res_json['message'] == 'success'
          return res_json['data']
        else
          return res_json['message']
        end
      else
        fail JSON.parse(res.body)['message']
      end
    end

    def all member
      #客服列表
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['member_service']}?member_email=#{member.email}&auth_token=#{member.auth_token}")
      res = Net::HTTP.get_response(uri)
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        JSON.parse(res.body).map do |member_service|
          MemberService.new member_service.merge!(member: member)
        end
      else
        fail JSON.parse(res.body)['message']
      end
    end

    def find member, id
      #客服show頁
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['member_service']}/#{id}?member_email=#{member.email}&auth_token=#{member.auth_token}")
      res = Net::HTTP.get_response(uri)
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        return MemberService.new JSON.parse(res.body)
      else
        fail JSON.parse(res.body)['message']
      end
    end
    alias_method :find_by_member_and_id, :find
    alias_method :find_by_id, :find

    private

    def hash_regenerate! attributes
      new_params = Hash.new
      attributes.each do |root_key, root_value|
        new_value = root_value
        new_key = 'm__'
        case root_key
        when :comment, 'comment'
          new_key = 'm__c__'
          attributes[root_key].each do |child_key, child_value|
            new_value = child_value
            new_key = "m__c__#{child_key}"
            if child_value.kind_of?(ActionController::Parameters)
              new_key = "m__c__#{child_key}__"
              attributes[root_key][child_key].each do |grand_key, grand_value|
                new_value = grand_value
                new_key = "m__c__#{child_key}__#{grand_key}"
                new_params.merge! :"#{new_key}" => new_value
                new_key = "m__c__#{child_key}__"
              end
            else
              new_params.merge! :"#{new_key}" => new_value
              new_key = 'm__c__'
            end
          end
        when :member_email, 'member_email', :auth_token, 'auth_token'
          new_key = "#{root_key}"
        else 
          new_key << "#{root_key}"
        end
        if new_key.last != '_'
          new_params.merge! :"#{new_key}" => new_value
        end
      end
      new_params
    end

  end

  def attributes
    ATTRS.map {|key| [key, nil]}.to_h
  end

  def attributes=(hash)
    hash.each do |key, v|
      send("#{key}=", v)
    end
  end

  def comment
    @comment ||= Comment.new
  end

  def comment= attributes
    @comment = Comment.new attributes
  end
end