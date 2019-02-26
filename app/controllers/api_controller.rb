class ApiController < ApplicationController
  def index
    @countries = WorldbankApi.countries()

    render json: @countries
  end

  def show
    country_code = params[:id]
    country = WorldbankApi.get_country(country_code)
    to_year = ( params[:to_year] or params[:year] or WorldbankApi.current_year ).to_i
    from_year = ( params[:from_year] or (to_year-20) ).to_i
    range = (from_year..to_year)
    @data = WorldbankApi.country_data(country, range)

    render json: @data
  end
end