require 'rest-client'
require 'addressable/uri'
require 'json'
require 'debugger'
require_relative 'api_key'

class IceCreamFinder
  def get_address
    print "Enter your current address: "
    gets.chomp.strip
  end

  def parse_json(url)
    results = JSON.parse(RestClient.get(url))
    if results["status"] == "OK"
      results
    else
      raise StandardError.new results["status"]
    end
  end

  def get_coordinates(address)
    url = Addressable::URI.new(
      :scheme => "http",
      :host => "maps.googleapis.com",
      :path => "maps/api/geocode/json",
      :query_values => {:address => address,
                        :sensor => false}).to_s
      coords = parse_json(url)
      coords["results"][0]["geometry"]["location"].values.join(",")
  end

  def find_ice_cream_shops(coords)
    url = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/place/nearbysearch/json",
      :query_values => {:location => coords,
                        :radius => 800,
                        :types => "food",
                        :keyword => "ice cream",
                        :sensor => false,
                        :key => APIKey.api_key}).to_s
    ice_cream = parse_json(url)
    ice_cream["results"][0]["geometry"]["location"].values.join(",")
  end

  def get_directions(from, to)
    url = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/directions/json",
      :query_values => {:origin => from,
                        :destination => to,
                        :sensor => false}).to_s
    directions = parse_json(url)
    directions["routes"][0]["legs"][0]["steps"].each_with_index do |step, index|
      puts "Step #{index + 1}:"
      puts step["html_instructions"].gsub(/<.*?>/, "")
      puts step["duration"]["text"]
      puts "======="
    end
  end

  def ice_cream_finder
    from = get_coordinates(get_address)
    to = find_ice_cream_shops(from)
    get_directions(from, to)
  end
end

IceCreamFinder.new.ice_cream_finder

