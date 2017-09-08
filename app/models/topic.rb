class Topic < Base

  attr_accessor :id, :name, :image_url, :"description"

  class << self
    def all
      Rails.cache.fetch("WEB/topics/all", expires_in: 15.minutes) do
        fetch_topics()["at_header"].map do |topic|
          Topic.new(id: topic["id"],
                    name: topic["name"],
                    image_url: topic["image_url"])
        end
      end
    end

    def list_at_side_bar
      Rails.cache.fetch("WEB/topics/list_at_side_bar", expires_in: 15.minutes) do
        fetch_topics()["at_side_bar"].map do |topic|
          Topic.new(id: topic["id"],
                    name: topic["name"],
                    image_url: topic["image_url"])
        end
      end
    end

    private

    def fetch_topics()
      Rails.cache.fetch("WEB/fetch_topics", expires_in: 10.minutes) do
        uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['classifications']}")
        JSON.parse(Net::HTTP.get(uri))['topics']
      end
    end
  end

  def gamaitems
    Rails.cache.fetch("WEB/topics/#{id}", expires_in: 5.minutes) do
      uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['topics']}/#{id}")
      # uri = URI("https://api.gamadian.com/api/v9/topics/#{id}")
      rsp = JSON.parse Net::HTTP.get(uri)

      gamaitems = rsp["gamaitems"].map do |gamaitem|
        Gamaitem.new gamaitem
      end

      meta = rsp.slice("image_url", "description", "name")

      [gamaitems, meta]
    end
  end

end
