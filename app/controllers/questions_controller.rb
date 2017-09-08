class QuestionsController < ApplicationController
  def index
    if !signed_in?
      redirect_to members_signin_path
    elsif session[:order_json].blank?
      redirect_to :back, alert: '沒有訂單資料，請重新選擇'
    else
      @order = Order.new.from_json(session[:order_json])
    end
  end
end
