require 'rest-client'
require 'json'
require 'redis'

class LocationsController < ApplicationController

  def submit
    # POST locations with required ip address query parameter
    # Query GeoJS Location by IP Address endpoint
    ip_address = params[:ip]
    body = RestClient.get("https://get.geojs.io/v1/ip/geo.json", headers: {params: {ip: ip_address}})
    
    # Parse JSON response for city and country fields
    # Save city and country fields to Location model to be saved to cache
    parsed = JSON.parse(body)
    loc = Location.create(:city => parsed["city"], :country => parsed["country"])

    # Setup and store IP_Address, Location pairs to cache
    #cache = ActiveSupport::Cache::MemoryStore.new
    #cache.write(ip_address, loc)
    #puts Rails.cache.instance_variable_get("@data")
    Rails.cache.write(ip_address, loc)
    
    # TODO: Proper Response model
    # Unit Tests
    # Cover edge cases
    render json: body
  end

  def data
    redis = Redis.new(url: ENV["127.0.0.1:6379"])
    puts redis.keys("*")
  end
end
