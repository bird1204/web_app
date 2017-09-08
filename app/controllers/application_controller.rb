class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :save_jump_location, :fetch_header_menu, :save_utm_session, :save_ichannel, :update_utm, :set_variant, :get_hot_keywords
  around_action :cart_management
  after_action -> { flash.discard }, if: -> { request.xhr? }


  def apple_app_site_association
  end

  def routing_error
    render status: 200, json: {message: 'WRONG DOMAIN, TRY api.gamadian.com'}
  end

  def save_utm_session
    # localhost:3000/?utm_source=gmdfb&utm_medium=nonpaid&utm_campaign=red_envelope&utm_term=&utm_content=&_branch_match_id=285317310898584268
    # http://localhost:3000/?utm_source=gmdfb&utm_medium=nonpaid&utm_campaign=red_envelope&utm_term=&utm_content=&_branch_match_id=285317310898584268
    if params[:utm_source].blank? && params[:utm_medium].blank? && params[:utm_campaign].blank? && params[:utm_term].blank? && params[:utm_content].blank?
      if request.referer.present? and URI("#{request.referer}").host.match(/^(www)?\.google(\.[a-z]+)|(\.[a-z]+)$/).present?
        session[:utm] = { source: 'google', medium: 'organic', campaign: 'none', term: CGI::parse("#{URI(%Q(request.referer)).query}").to_h["q"], content:nil }
        session[:order_utm] = { source: 'google', medium: 'organic', campaign: 'none', term: CGI::parse("#{URI(%Q(request.referer)).query}").to_h["q"], content:nil }
      end
      if session[:utm].blank?
        session[:utm] = { source: 'direct', medium: 'nonpaid', campaign: 'none', term: nil, content:nil }
      end
      if session[:order_utm].blank?
        session[:order_utm] = { source: 'direct', medium: 'nonpaid', campaign: 'none', term: nil, content:nil }
      end
    else
      if session[:utm].blank?
        session[:utm] = { source: params[:utm_source], medium: params[:utm_medium], campaign: params[:utm_campaign], term: params[:utm_term], content: params[:utm_content] }
      end
      if session[:order_utm].blank?
        session[:order_utm] = { source: params[:utm_source], medium: params[:utm_medium], campaign: params[:utm_campaign], term: params[:utm_term], content: params[:utm_content] }
      end
    end
    return if session[:utm_expired_at].present?
    session[:utm_expired_at] = Time.zone.now.tomorrow
  end

  # Save iChannel gid
  def save_ichannel
    if params[:gid].present?
      cookies[:gid] = {
        value: params[:gid],
        expires: 7.days.from_now
      }
    end
  end

  def update_utm
    return unless current_member.present? && session[:utm].present? && session[:utm_expired_at] >= Time.zone.now
    # http://localhost:3000/gamaitems/121?source=direct&medium=nonpaid&campaign=none
    current_member.origin = session[:utm]
    session[:utm_expired_at] = Time.zone.now
  end

  def save_jump_location
    session[:jump_location] = params[:next] if params[:next].present?
  end

  def jump
    redirect_to session[:jump_location] || root_path
  end

  def cart_management
    session[:cart_json] ||= Cart.new(raw_line_items: Array.new).to_json
    @cart = Cart.new.from_json(session[:cart_json])


    begin
      if JSON.parse(session[:cart_json])["synced"]
        line_item_hash = Hash.new
        uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['gamaitem_memberships']}?auth_token=#{current_member.auth_token}&email=#{current_member.email}")
        JSON.parse(Net::HTTP.get(uri)).each { |rsp| line_item_hash = line_item_hash.merge("#{rsp['id']}" => rsp['quantity'].to_i) }
        @cart.raw_line_items = line_item_hash
      else
        gamaitems = Array.new
        JSON.parse(session[:cart_json])['raw_line_items'].each do |gamaitem_id, quantity|
          gamaitems << [Gamaitem.find_by_id(gamaitem_id), quantity]
        end
        @cart.sync gamaitems, current_member
      end
      @cart.mark_as_synced!
    rescue TypeError => e
      session[:member_json] = nil
    end if current_member.present?

    yield

    @cart.mark_as_unsynced! if !current_member.present?
    if !@cart.done
      session[:cart_json] = @cart.to_json
    else
      session[:cart_json] = nil
    end
  end

  def fetch_header_menu
    @topic_menu = Topic.all
    @side_bar_topics = Topic.list_at_side_bar
    @classifications = Classification.classifications
    @countries = Classification.countries
  end

  def current_member
    if signed_in?
      Member.new.from_json(session[:member_json])
    end
  end

  def signed_in?
    session[:member_json].present?
  end

  def legacy_gamaitem
    redirect_to gamaitem_path(id: params[:item_id])
  end

  def set_variant
    @browser = Browser.new(request.user_agent, accept_language: "zh-TW")
    request.variant = :phone if @browser.device.mobile?
    request.variant = :phone if @browser.device.tablet?
  end

  def get_hot_keywords
    @keywords = KeyWord.get_list
  end

  helper_method :current_member, :signed_in?

end
