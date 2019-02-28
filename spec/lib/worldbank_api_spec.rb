require 'rails_helper'

describe "WorldbankApi" do
  before :each do
    Rails.cache.clear
    world_countries_xml = File.read "#{Rails.root}/spec/lib/world_countries.xml"
    stub_request(:get, /\/v2\/country.*/)
      .to_return(body: world_countries_xml, headers: { 'Content-Type' => "text/xml" })
  end

  it "has the method 'countries'" do
    expect(WorldbankApi).to respond_to 'countries'
  end

  it "has the method 'country_data" do
    expect(WorldbankApi).to respond_to 'country_data'
  end

  it "has the method 'get_country'" do
    expect(WorldbankApi).to respond_to 'get_country'
  end

  describe "countries" do
    it "finds several countries" do
      expect(WorldbankApi.countries).not_to be_empty
    end

    it "finds names for all found countries" do
      expect(WorldbankApi.countries).to all(respond_to "name")
    end

    it "finds codes for all countries" do
      expect(WorldbankApi.countries).to all(respond_to "code")
    end

    it "finds Finland" do
      expect(WorldbankApi.countries.map(&:name)).to include("Finland")
    end
  end

  describe "get_country" do
    it "finds something from the country code FI" do
      expect(WorldbankApi.get_country "FI").to be_truthy
    end

    it "finds nothing from the country code 'JA-GROHN'" do
      expect(WorldbankApi.get_country "JA-GROHN").to be_nil
    end

    it "finds a name from the country code FI" do
      expect(WorldbankApi.get_country "FI").to respond_to "name"
    end

    it "finds the name 'Finland'" do
      expect(WorldbankApi.get_country("FI").name).to eq "Finland"
    end
  end

  describe "country_data" do
    before :each do
      finland_population_xml = File.read "#{Rails.root}/spec/lib/finland_population_data.xml"
      stub_request(:get, /FI\/indicator\/SP\.POP\.TOTL.*/)
        .to_return(body: finland_population_xml, headers: { 'Content-Type' => "text/xml" })
      
      finland_co2_xml = File.read "#{Rails.root}/spec/lib/finland_co2_data.xml"
      stub_request(:get, /FI\/indicator\/EN\.ATM\.CO2\.KT.*/)
        .to_return(body: finland_co2_xml, headers: { 'Content-Type' => "text/xml" })
    end

    it "finds several data points" do
      finland = WorldbankApi.get_country "FI"
      expect(WorldbankApi.country_data finland).not_to be_empty
    end
  end
end