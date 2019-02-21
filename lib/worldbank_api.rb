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

  def self.get_all_regions_populations_data(last_page = population_database_last_page)
    (1..last_page).to_a.lazy.map{ |i| fetch_and_parse_regions_populations_data(i) }.reduce(&:concat)
  end

  def self.all_regions_populations_data(last_page)
    Rails.cache.fetch("POPDATA1TO#{last_page}", expires_in: 1.week.to_i){ get_all_regions_populations_data(last_page) }
  end

  private

  def self.fetch_and_parse_regions_populations_data(page=1)
    data = regions_populations_data(page)
    parse_regions_populations_data(data)
  end

  def self.population_database_last_page
    Rails.cache.fetch("POP_DATA_LAST_PAGE", expires_in: 1.month.to_i){ regions_populations_data(1).dig("data","pages").to_i }
  end

  def self.regions_populations_url(page=1)
    "http://api.worldbank.org/v2/country/all/indicator/SP.POP.TOTL?format=xml&page=#{page}"
  end

  def self.get_regions_populations_data(page=1)
    url = regions_populations_url(page)
    HTTParty.get(url).parsed_response
  end

  def self.regions_populations_data(page=1)
    Rails.cache.fetch("POPDATA#{page}", expires_in: 1.month.to_i){ get_regions_populations_data(page)}
  end

  def self.country_population_data_to_open_struct(hash)
    name = hash.dig("country","__content__")
    year = hash.dig("date")
    population = hash.dig("value")
    OpenStruct.new(name: name, year: year, population: population)
  end

  # Parses a Hash.
  # In particular, parses a Hash obtained from 'HTTParty.get(country_populations_url).parsed_response'
  # where 'country_populations_url' is returned by the method of the same name.
  # This method shouldn't be used for anything else.
  def self.parse_regions_populations_data(hash)
    hash.dig("data","data")&.map{ |d| country_population_data_to_open_struct(d) }
  end

  
  def self.current_year
    Date.today.year
  end

  def self.find_regions(country)
    begin
      IsoCountryCodes.search_by_name(country)
    rescue
      []
    end
  end

  def self.to_iso_code(country)
    return "all" unless country
    find_regions(country)&.first&.alpha3 or "all"
  end

  def self.worldbank_url(country=nil, year=current_year, topic="population", table_format="xml")
    country_iso3 = to_iso_code(country)

    topics = {
      "population" => "SP.POP.TOTL",
      "co2" => "EN.ATM.CO2E.KT"
    }

    topic_tag = topics[topic]

    "http://api.worldbank.org/v2/country/#{country_iso3}/indicator/#{topic_tag}?date=#{year}&format=#{table_format}"
  end

end