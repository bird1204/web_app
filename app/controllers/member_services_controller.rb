class MemberServicesController < ApplicationController

  def index
    @member_services = current_member.member_services
  end

  def new
    @member_service = MemberService.new
    if session[:order_json].present?
      @order = Order.new.from_json(session[:order_json])
      if %w(5 7 8 9).include? params[:question_id]
        @order = current_member.find_order_by_id(@order.ordernumber)
      end
    end
  end

  def create
    member_service_message = MemberService.create! member_service_params.merge!(member_email: current_member.email, auth_token: current_member.auth_token)
    if member_service_message.to_i > 0
      redirect_to member_service_path(member_service_message)
    else
      fail member_service_message
    end
  rescue StandardError => e
    redirect_to :back, alert: "[錯誤]#{e}，請聯絡客服"
  end

  def show
    @member_service = current_member.member_services.find_by_id(params[:id])
  end

  def images
    render json: {url: params['member_services']['images_url'], filename: params['filename']}
  end

  private

  def member_service_params
    val = params.require(:member_service).permit(
      :order_id,
      :contact,
      :contact_method,
      :question_id,
      :images_url,
      comment: [
        :reason,
        :message,
        :place,
        :price,
        :question,
        :name,
        :city_area,
        :city,
        :address,
        :phone,
        :content,
        invoice: [
          :type,
          :carrier_type,
          :carrier_num,
          :buyer_ubn,
          :city_area,
          :city,
          :address,
          :foundation_id
        ],
        head: [
          :id,
          :name,
          :quantity
        ],
        account: [
          :bank,
          :identify,
          :account,
          :name
        ],
        cargo: [
          :name,
          :city,
          :city_area,
          :address,
          :phone
        ]
      ]
    )
    if val[:comment][:head].present?
      val[:comment][:head] = val[:comment][:head].collect{ |k,v| "#{v[:id]}-#{v[:name]}-#{v[:quantity]}" if v[:quantity].to_i > 0}.compact.join(',')
    end
    return val
  end

end
