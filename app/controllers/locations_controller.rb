require 'rest-client'
require 'json'
require 'httparty'

# There would ideally be unit tests to ensure full code coverage
class LocationsController < ApplicationController

  # I regret the usage of a global variable but given the small scope of this project, I chose to use one
  # due to self imposed time constraints and my incomplete knowledge of the Ruby on Rails framework.
  # The original intent was to somehow cache every response from GeoJS in key value pairs of the
  # IP Address' used to query GeoJS, and the respective location data responses.
  # I know that Rails.cache.instance_variable_get(:@data) returns the key value pairs and that
  # it is possible to just return either keys or values. But I wasn't able to figure out how to return every 
  # corresponding key, value pair individually. 
  # I thought that I could iterate through the response of Rails.cache.instance_variable_get(:@data)
  # as if it were a hashmap like struct, but I do not know what is the return type.
  # Apologies for the inelegant solution
  $arr = Array.new

  def submit
    # POST /locations/submit with required ip address query parameter
    # Query GeoJS Location by IP Address endpoint
    # Due to time constraints I am not addressing possible edge cases of improper user input.
    # In this case it would be for a nonexistent IP Address. 
    # For covering that case I found that the GeoJS API will always return a 200 OK response no matter what the IP Address passed in is.
    # So the only way I see to detect such an edge case would be to do a check on the "longitude" or "latitude" fields 
    # As those are "nil" for nonexisting IP Addresses. Other fields do not give consistent enough responses. 
    # Of course that is just an assumption, the logical course of action would be to first contact the GeoJS team to ensure that we fully 
    # understand how their API functions. 
    ip_address = request.headers["ip"]
    query = {
      "ip" => ip_address
    }

    body = HTTParty.get(
      # Ideally lines like this URL would not be hard coded and would be stored elsewhere
      "https://get.geojs.io/v1/ip/geo.json",
      :query => query
    )
    
    # Parse JSON response for city and country fields
    # Save city and country fields to Location model to be saved to cache
    # Based off testing with the GeoJS API, it is possible for the city field to not be filled in the response
    # For example, IP Address 156.74.181.208 should correspond to Seattle, USA but only the country is returned
    parsed = body.parsed_response
    if !parsed[0]["city"].nil?
      city = parsed[0]["city"]
    else
      city = ""
    end
    loc = Location.create(:city => parsed[0]["city"], :country => parsed[0]["country"])

    # Setup and store IP_Address, Location pair to cache
    # IP_Address is then also saved to the global array. Then def data is called by the GET /locations/data endpoint.
    # The array is then iterated through to retrieve the individual corresponding values for returning
    # all IP addresses tracked with associated data in a JSON response.
    # Ensure that no duplicate ip_address, location pairs are added
    if Rails.cache.read(ip_address).nil?
      Rails.cache.write(ip_address, loc)
      $arr.push(ip_address)
    end
    
    # Within the alloted time I did not have time to implement proper error handling.
    # The idea is that this response model will be able to return varying HTTP status codes and descriptions 
    # and that none of it would be hard coded here. 
    response = SubmitResponse.create(:status_code => "200", :description => "Country/city fetched from GeoJS and stored into server memory cache")
    render json: response
  end

  # Supports passing in either no header, or a city/country header. 
  # (Due to the wording and my assumption based off the intended time constraint, 
  # I am only covering the case where either the city or country header is passed in
  # not both at the same time)
  def data
    # GET /locations/data returns an array of DataResponse in JSON 
    # Each element of the array represents each IP Address tracked 
    # and the associated data.
    ary = Array.new
    # In the case where a city header is passed in, only return data of the queried city
    if !request.headers["city"].nil?
      $arr.each { |ip_address|
        loc = Rails.cache.read(ip_address)
        if loc.city.eql?request.headers["city"]
          ary.push(DataResponse.create(:ip_address => ip_address, :city => loc.city, :country => loc.country))
        end
      }
    # In the case where a country header is passed in, only return data of the queried city
    elsif !request.headers["country"].nil?
      $arr.each { |ip_address|
        loc = Rails.cache.read(ip_address)
        if loc.country.eql?request.headers["country"]
          ary.push(DataResponse.create(:ip_address => ip_address, :city => loc.city, :country => loc.country))
        end
      }
    # When no header is passed in, return all queried city data
    else
      # For each ip_address that has been searched with POST /locations/submit
      # retrieve the corresponding location data from cache and append the relevant
      # (city and country) data to the array to be returned.
      $arr.each { |ip_address|
        loc = Rails.cache.read(ip_address)
        ary.push(DataResponse.create(:ip_address => ip_address, :city => loc.city, :country => loc.country))
      } 
    end
    render json: ary
  end
end
