class WorldbankApi
  def self.country_data(country="all", year=current_year)
    Rails.fetch("#{to_iso_code(country)}#{year}", expires_in: 1.week.to_i) { get_country_data(country) }
  end

  def self.get_country_data(country="all", year=current_year)
    co2_url = worldbank_url(country,year,"co2")
    population_url = worldbank_url(country,year,"population")
    
    co2 = HTTParty.get(co2_url).parsed_response.dig(1,0,"value")
    population = HTTParty.get(population_url).dig(1,0,"value")

    OpenStruct.new( population: population, co2: co2 )
  end

  private
  def self.current_year
    Date.today.year
  end

  def self.find_countries(country)
    begin
      IsoCountryCodes.search_by_name(country)
    rescue
      []
    end
  end

  def self.to_iso_code(country)
    return "all" unless country
    find_countries(country)&.first&.alpha3 or "all"
  end

  def self.worldbank_url(country, year=current_year, topic="population")
    country_iso3 = to_iso_code(country)

    topics = {
      "population" => "SP.POP.TOTL",
      "co2" => "EN.ATM.CO2E.KT"
    }

    topic_tag = topics[topic]

    "http://api.worldbank.org/v2/country/#{country_iso3}/indicator/#{topic_tag}?date=#{year}&format=json"
  end

end