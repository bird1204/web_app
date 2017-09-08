class ConvenienceStoresController < ApplicationController

  def forward
    uri = URI("#{API_ROUTE['host']}#{API_ROUTE['latest']['convenience_stores']}/#{params[:path] || ''}")
    # uri = URI("https://api.gamadian.com/api/v9/convenience_stores/#{params[:path] || ''}")
    uri.query = URI.encode_www_form(request.query_parameters)
    render json: JSON.parse(Net::HTTP.get(uri))
  end

end
