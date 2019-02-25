class WorldbankApi
  # Lists countries.
  def self.countries
    Rails.cache.fetch("COUNTRIES"){ get_countries() }
  end

  # Get specific country from ISO 2 code
  def self.get_country(country_code)
    countries.detect{ |c| c.code == country_code }
  end

  # Gets information about the country from a specific year.
  def self.country_data(country, range=(current_year..current_year))
    Rails.cache.fetch("#{country.code}#{range}", expires_in: 1.week.to_i) { get_country_data(country, range) }
  end

  # Fetches an array of all the countries in the world.
  def self.get_countries
    url = country_list_url(1)
    last_page = HTTParty.get(url).parsed_response.dig("countries","pages").to_i

    (1..last_page).to_a.lazy
      .map{ |i| country_list_url(i) }
      .map{ |url| HTTParty.get(url).parsed_response }
      .map{ |hash| hash.dig("countries", "country") }
      .map{ |country_list| country_list.map{ |hash| hash_to_country(hash) } }
      .reduce(&:concat)
  end

  # CountryData is an OpenStruct with a country, a population, CO2, and a year.
  def self.get_country_data(country, range=(current_year..current_year))
    co2_url = country_data_url(country,range,"co2")
    population_url = country_data_url(country,range,"population")
    
    co2 = HTTParty.get(co2_url).parsed_response.dig("data","data")&.map{ |h| h.dig("value").to_f }
    population = HTTParty.get(population_url).dig("data","data")&.map{ |h| h.dig("value").to_i }

    range.to_a
      .map{ |year|
        CountryData.new(
          country: country,
          year: year,
          population: population&.fetch(year-range.last),
          co2: co2&.fetch(year-range.last)
        )
      }
  end

  def self.get_country_history(country, years)

  end

  def self.current_year
    Date.today.year
  end

  def self.country_list_url(page=1)
    "http://api.worldbank.org/v2/country?page=#{page}"
  end

  def self.country_data_url(country, range=(0..0), topic="population")
    topics = {
      "population" => "SP.POP.TOTL",
      "co2" => "EN.ATM.CO2E.KT"
    }

    topic_tag = topics[topic]

    "http://api.worldbank.org/v2/country/#{country.code}/indicator/#{topic_tag}?date=#{range.first}:#{range.last}&format=xml"
  end

  # Countries are OpenStructs with a name and an ISO2 code.
  def self.hash_to_country(hash)
    Country.new(code: hash.dig("iso2Code"), name: hash.dig("name") )
  end
end