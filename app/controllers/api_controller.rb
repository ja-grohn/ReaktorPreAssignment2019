class ApiController < ApplicationController
  def index
    @countries = WorldbankApi.countries()

    api_render @countries
  end

  def show
    country_code = params[:id]
    country = WorldbankApi.get_country(country_code)
    year = params[:year]
    from_year = params[:from_year]
    to_year = params[:to_year]
    range =
      if from_year and to_year
        (from_year.to_i .. to_year.to_i)
      elsif year
        y = year.to_i
        (y .. y)
      else
        y = WorldbankApi.current_year
        (y-20..y)
      end
    @data = WorldbankApi.country_data(country, range)

    api_render @data
  end

  private
  
  def api_render(table)
    case params[:format]
    when "json"
      render json: table
    when "xml"
      render xml: table
    else
      render json: table
    end
  end
end