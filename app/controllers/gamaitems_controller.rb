class GamaitemsController < ApplicationController

  def index
    @gamaitems, @meta = Rails.cache.fetch("WEB/gamaitems?page=#{params[:page]}", expires_in: 5.minutes) do
      Gamaitem.page params[:page] || 1
    end
    @classifications = Classification.classifications
    @countries = Classification.countries

    @topics = @topic_menu.map.with_index{|a, index|
      index.odd? ? [@topic_menu[index-1] , a] : nil
    }.compact

    @topics.pop if @topic_menu.size.odd? 
  end

  def show
    @gamaitem = Gamaitem.find_by_id(params[:id])
  end

  def search
    @gamaitems, @meta = Rails.cache.fetch("WEB/gamaitems/search?keyword=#{params[:keyword]}&page=#{params[:page]}", expires_in: 5.minutes) do
      Gamaitem.search(params[:keyword], params[:page] || 1)
    end
  end

end
