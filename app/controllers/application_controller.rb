# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def index
    @interesting_countries = ["1W","XD","XL","US","EU","CN"].map{ |code| WorldbankApi.get_country code }

  end
end
