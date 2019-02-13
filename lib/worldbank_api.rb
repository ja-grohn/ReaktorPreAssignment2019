class WorldbankApi
  def country_data(country="all", year=current_year)
    Rails.cache.fetch()
  end

  def self.get_country_data(country="all", year=current_year)
    co2_url = worldbank_url(country,year,"co2")
    population_url = worldbank_url(country,year,"population")
    
    co2 = HTTParty.get(co2_url).parsed_response[1]["value"]
    population = HTTParty.get(population_url).parsed_response[1]["value"]

    OpenStruct.new{ population: population, co2: co2 }
  end

  private
    def current_year
      Date.today.year
    end

    def find_countries(country)
      begin
        IsoCountryCodes.search_by_name(country)
      rescue
        []
      end
    end

    def to_code(country)
      return "all" unless country
      find_countries(country).first?.alpha3 or "all"
    end

    def worldbank_url(country, year=current_year, topic="population")
      country_iso3 = to_code(country)

      topic_tag = case topic
        when "population" "SP.POP.TOTL"
        when "co2" "EN.ATM.CO2E.KT"
      end

      "http://api.worldbank.org/v2/country/#{country_iso3}/indicator/EN.ATM.CO2E.KT?year=#{year}&format=json"
    end
end