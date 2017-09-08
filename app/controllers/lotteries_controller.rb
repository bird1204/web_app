class LotteriesController < ApplicationController
  layout false
  def index
    render :index
  end

  def minions
    render :minions
  end

  def pink_daily
    render :pink_daily
  end

  def create
    render json: Lottery.draw(phone_num: params[:phone_num], type: params[:type])
  end
end
