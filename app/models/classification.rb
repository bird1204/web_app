class Classification < Base

  attr_accessor :id,
    :name,
    :thumbnail,
    :long_thumbnail,
    :total_page

  class << self
    def all
      # classifications + countries
      collection = Array.new
      classifications.each{|father, sons| collection += sons}
      collection + countries
    end

    def classifications
      # Classification.fetch_classifications['classifications'].map do |classification|
      #   Classification.new id: classification
      # end
      collection = Hash.new
      fetch_classifications['classifications'].each do |father, sons|
        collection.merge!({
                            father => sons.map do |name, id|
                              Classification.new(id: id, name: name, thumbnail: '', long_thumbnail: '')
                            end
        })
      end
      collection
    end

    # Classification.countries
    def countries
      # fetch_classifications['countries'].map do |classification|
      #   Classification.new classification
      # end
      fetch_classifications['countries'].map do |name, id|
        Classification.new(id: id, name: name, thumbnail: '', long_thumbnail: '')
      end
    end

    def find_by_id(id)
      all.find {|classification| classification.id.to_i == id.to_i}
    end

    def find_by_name(name)
      all.find {|classification| classification.name == name}
    end

    # private
    def fetch_classifications()
      # Rails.cache.fetch("WEB/classifications", expires_in: 5.minutes) do
      #   uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['classifications']}")
      #   JSON.parse Net::HTTP.get(uri)
      # end
      v_four_classification
    end

    def v_four_classification
      {
        'classifications' => {
          "餅乾" => {
            "所有商品" => 279,
            "洋芋片 " => 280,
            "餅乾棒/捲心酥" => 285,
            "其他鹹餅乾" => 291,
            "其他甜餅乾" => 299
          },
          "糖果/巧克力" => {
            "所有商品" => 306,
            "軟糖" => 307,
            "硬糖" => 313,
            "巧克力" => 321,
            "牛奶糖" => 328,
            "棉花糖" => 329,
            "口香糖" => 330,
            "其他" => 331
          },
          "泡麵/即食" => {
            "所有商品" => 332,
            "日式泡麵" => 333,
            "韓式泡麵" => 339,
            "東南亞泡麵" => 345,
            "年糕/飯/湯" => 351,
            "其他" => 352,
            "辣泡麵" => 353,
            "煮泡麵" => 358
          },
          "罐裝/沖泡飲品" => {
            "所有商品" => 359,
            "沖泡飲品" => 360,
            "罐裝飲料" => 365
          },
          "蛋糕/食玩/果乾" => {
            "所有商品" => 366,
            "蛋糕" => 367,
            "食玩DIY" => 368,
            "饅頭點心" => 369,
            "果凍" => 370,
            "果乾" => 371,
            "其他" => 372
          },
          "下酒菜/海苔/起司" => {
            "所有商品" => 373,
            "海鮮" => 374,
            "海苔" => 375,
            "起司" => 376,
            "堅果" => 377,
            "其他" => 378
          },
          "生活類" => {
            "所有商品" => 379
          }
        },
        'countries' => {
          "日本" => 381,
          "韓國" => 382,
          "東南亞" => 383,
          "台港澳" => 384,
          "歐美" => 385
        }
      }
    end

  end

  def parentize! name=nil
    self.name = name
    self
  end

  def self_and_ancestors
    path = Array.new
    Classification.classifications.each do |parent, children|
      next unless children.find{|classification| classification.id == id}.present?
      path << children.find{|classification| classification.id == id}
      path << children.first.parentize!(parent)
    end
    path.uniq.reverse!
  end

  def gamaitems(page=1, sort_id=1)
    Rails.cache.fetch("WEB/classifications/#{id}/#{page}/#{sort_id}", expires_in: 5.minutes) do
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['gamaitems']}?id=#{id}&page=#{page}&sort=#{sort_id}")
      # uri = URI("https://api.gamadian.com/api/v9/gamaitems/?id=#{id}&page=#{page}&sort=#{sort}")
      rsp = JSON.parse Net::HTTP.get(uri)

      gamaitems = rsp["gamaitems"].map do |gamaitem|
        Gamaitem.new gamaitem
      end

      meta = rsp.slice("covers", "total_page")

      [gamaitems, meta]
    end
  end

  def filter(page=1, sort_id=1, tag_ids="", area_ids="")
    Rails.cache.fetch("WEB/classifications/#{id}/#{page}/#{sort_id}/#{tag_ids}/#{area_ids}", expires_in: 5.minutes) do
      tag_ids = tag_ids.join(',') if tag_ids.kind_of?(Array)
      area_ids = area_ids.join(',') if area_ids.kind_of?(Array)
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['filter']}?classification_id=#{id}&page=#{page}&sort=#{sort_id}&area_ids=#{area_ids}&tag_ids=#{tag_ids}")
      rsp = JSON.parse Net::HTTP.get(uri)

      gamaitems = []
      if rsp["gamaitems"]
        gamaitems = rsp["gamaitems"].map do |gamaitem|
          Gamaitem.new gamaitem
        end
      end

      meta = rsp.slice("covers", "total_page", "topics")

      tags = rsp["tags"].map do |tag|
        Tag.new tag
      end
      areas = rsp["areas"].map do |area|
        Area.new area
      end

      tags_hash = Hash.new
      tags.each do |tag|
        if tags_hash[tag.action].blank?
          tmp = Array.new
          tmp << tag
          tags_hash[tag.action] = tmp
        else
          tags_hash[tag.action] << tag
        end
      end
      [gamaitems, meta, tags_hash, areas]
    end
  end

end
