class CountriesController < ApplicationController
  def index
    @countries = WorldbankApi.countries().sort_by(&:name)
  end

  def show
    country_code = params[:id]
    country = WorldbankApi.get_country(country_code)
    year = WorldbankApi.current_year
    range = (year-20..year)
    @data = WorldbankApi.country_data(country, range)
  end
end