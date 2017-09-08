class MembersController < ApplicationController

  def require_email
  end

  def update
    session[:member_json] = current_member.update_attributes!(
      new_email: params[:new_email],
      new_password: params[:new_password],
      password: params[:password],
      name: params[:name],
      phone_number: params[:phone_number],
      birthday: params[:birthday],
      gender: params[:gender]
    ).to_json
    redirect_to edit_members_path, :notice => "修改成功"
  rescue StandardError => e
    redirect_to edit_members_path, :alert => "修改失敗：#{e}"
  end

  def show_signin
  end

  def signin
    email, password, user_id, facebook_token = nil
    provider = params.require(:provider)
    case provider
    when 'facebook'
      email, user_id, facebook_token = params.require([:email, :user_id, :facebook_token])
    when 'direct'
      email, password = params.require([:email, :password])
    end
    @member = Member.login(email, password, provider, user_id, facebook_token)
    if @member.present?
      session[:member_json] = @member.to_json
      jump
    else
      redirect_to members_signin_path, :alert => "帳號或密碼錯誤"
      return
    end
  end

  def show_signin_cart
    if signed_in?
      redirect_to carts_checkout_path
    end
  end

  def signout
    # http://api.gamadian.com/api/v9/members/sign_out
    reset_session
    redirect_to root_path
  end

  def show_signup
  end

  def signup
    # http://api.gamadian.com/api/v9/members.json?email=supermfb@gmail.com&password=1234&device_id=84108c3f-9182-300a-ba78-8a25eedb81d0
    email, password, confirm_password = params.require([:email, :password, :confirm_password])

    if password != confirm_password
      redirect_to members_signup_path, alert: "輸入的密碼不一致"
    else
      member, err = Member.create_by_email_password(email, password)
      if member.present?
        session[:member_json] = member.to_json
        jump
      else
        redirect_to members_signup_path, alert: err
      end
    end
  end

  def show_reset_password
    # members/password/new
  end

  def reset_password
    uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['new_password']}")
    # uri = URI('https://api.gamadian.com/api/v9/members/password/new')
    uri.query = URI.encode_www_form({
                                      email: params[:email]
    })
    rsp = JSON.parse Net::HTTP.get(uri)
    if rsp['message'] == "success"
      redirect_to members_reset_password_path, notice: "請至信箱收信並重設密碼．謝謝"
    else
      redirect_to members_reset_password_path, alert: rsp['message']
    end
  end

  def show
    # profiles
  end


  def orders
    if !signed_in?
      redirect_to members_signin_path
    else
      @orders = current_member.orders
      params[:show] ||= "ing"
    end
  end

  def find_order_by_id

    if !signed_in?
      redirect_to members_signin_path
    else
      @order = current_member.find_order_by_id(params[:id])
      if !@order.present?
        redirect_to members_orders_path, alert: session[:order_json]
      end
      session[:order_json] = {
        ordernumber: @order.ordernumber,
        name: @order.name,
        phone: @order.phone,
        situation_of_cargo_id: @order.situation_of_cargo_id,
        deliverymethod: @order.deliverymethod
      }.to_json
    end
  end

  def coupons
    if !signed_in?
      redirect_to members_signin_path
    else
      @coupons = current_member.coupons
    end
  end

  def invalidate
    provider, user_id, facebook_token = params.require([:provider, :user_id, :facebook_token])
    email = begin
      params.require([:email])
    rescue
      nil
    end
    render json: Member.invalidate_fb_user(email, provider, user_id, facebook_token)
  end
end
