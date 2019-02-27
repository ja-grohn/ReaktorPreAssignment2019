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

  def search
    searched_country = params[:country]
    @countries = WorldbankApi.countries().select{ |country|
      country.name.downcase.match? searched_country or country.code == searched_country
    }
    if @countries.empty?
      redirect_back(fallback_location: root_path, notice: "Found no results.")
    else
      render :index
    end
  end
end