class Gamaitem < Base
  include ActionView::Helpers::SanitizeHelper

  attr_accessor :id,
    :area_id,
    :area_name,
    :area_name_en,
    :area_poster_url,
    :classification_id,
    :classification_ids,
    :description,
    :description_txt,
    :features,
    :hotsell,
    :is_buy,
    :name,
    :original_price,
    :price,
    :product_image,
    :product_images,
    :related_gamaitems,
    :related_str,
    :sku,
    :specification,
    :tag,
    :videos,
    :volume,
    :maximum_purchase_quantity

  attr_writer :weight,
    :longest_edge,
    :second_edge,
    :end_edge

  def id
    @id.to_s
  end

  def sku
    @sku.to_i
  end

  def weight
    @weight.to_f
  end

  def longest_edge
    @longest_edge.to_f
  end

  def second_edge
    @second_edge.to_f
  end

  def end_edge
    @end_edge.to_f
  end

  def description_txt
    strip_tags @description_txt.remove(/\r\n/)
  end

  def classifications
    # XXX: classification_id is list of id
    classification_id.map do |id|
      Classification.find_by_id(id)
    end.compact
  end

  def classification
    classifications.first
  end

  def related_gamaitems
    @related_gamaitems.map do |related_gamaitem|
      Gamaitem.new(related_gamaitem).map_area!
    end
  end

  def map_area!
    if area_name.blank? and area_poster_url.match(/asset\/area\/(\d*)\/icon/).present?
      index = area_poster_url.match(/asset\/area\/(\d*)\/icon/)[1].to_i - 1
      self.area_name = %w(
          日本 韓國 泰國 印尼 台灣 芬蘭 德國 英國 波蘭
          美國 義大利 比利時 荷蘭 阿根廷 羅馬尼亞 馬來西亞 
          越南 捷克 希臘 新加坡 所有國家 澳門 法國 西班牙 
          斯里蘭卡 菲律賓
          )[index]
    end
    self
  end

  class << self
    def page(p=1)
      Rails.cache.fetch("WEB/gamaitems/#{p}", expires_in: 5.minutes) do
        uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['gamaitems']}?page=#{p}")
        # uri = URI("https://api.gamadian.com/api/v9/gamaitems?page=#{p}")
        rsp = JSON.parse Net::HTTP.get(uri)
        gamaitems = rsp["gamaitems"].map do |gamaitem|
          Gamaitem.new(gamaitem).map_area!
        end

        meta = rsp.slice("covers", "topics", "current_page", "next_page")
        [gamaitems, meta]
      end
    end

    def find_by_id(id)
      Rails.cache.fetch("WEB/gamaitems/#{id}", expires_in: 5.minutes) do
        uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['gamaitems']}/#{id}?scale=thumb")
        # uri = URI("https://api.gamadian.com/api/v9/gamaitems/#{id}?scale=thumb")
        rsp = JSON.parse Net::HTTP.get(uri)
        Gamaitem.new(rsp).map_area!
      end
    end

    def search text, page=1
      Rails.cache.fetch("WEB/gamaitems_search/#{text}/#{page}", expires_in: 5.minutes) do
        uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['search']}")
        uri.query = URI.encode_www_form(text: text, page: page)
        rsp = JSON.parse Net::HTTP.get(uri)
        gamaitems = rsp["gamaitems"].map do |gamaitem|
          Gamaitem.new(gamaitem).map_area!
        end
        meta = rsp.slice("covers", "total_page")
        [gamaitems, meta]
      end
    end
  end
end
