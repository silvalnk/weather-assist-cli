# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require_relative "codes"

module WeatherAssist
  class Error < StandardError; end
  class CityNotFound < Error; end
  class NetworkError < Error; end
  class UnexpectedJSON < Error; end

  Place = Struct.new(:name, :admin1, :country, :latitude, :longitude, keyword_init: true)
  Report = Struct.new(:place, :temperature_c, :apparent_c, :weather_code, :conditions, keyword_init: true)

  class Client
    GEOCODE_URL = "https://geocoding-api.open-meteo.com/v1/search"
    FORECAST_URL = "https://api.open-meteo.com/v1/forecast"
    TIMEOUT = 10

    def initialize(get: nil)
      @get = get
    end

    def current(city)
      place = geocode(city)
      forecast = fetch_json(forecast_url(place))
      self.class.parse_report(forecast, place)
    end

    def self.parse_place(payload, city)
      results = payload.is_a?(Hash) ? payload["results"] : nil
      raise UnexpectedJSON, "Unexpected JSON from geocoding API" unless results.is_a?(Array)

      hit = results.first
      raise CityNotFound, "City not found: #{city}" if hit.nil?
      raise UnexpectedJSON, "Unexpected JSON from geocoding API" unless hit.is_a?(Hash)
      if hit["name"].nil? || hit["latitude"].nil? || hit["longitude"].nil?
        raise UnexpectedJSON, "Unexpected JSON from geocoding API"
      end

      Place.new(
        name: hit["name"],
        admin1: hit["admin1"],
        country: hit["country"],
        latitude: hit["latitude"],
        longitude: hit["longitude"]
      )
    end

    def self.parse_report(payload, place)
      current = payload.is_a?(Hash) ? payload["current"] : nil
      raise UnexpectedJSON, "Unexpected JSON from forecast API" unless current.is_a?(Hash)

      temperature = current["temperature_2m"]
      apparent = current["apparent_temperature"]
      code = current["weather_code"]
      if temperature.nil? || apparent.nil? || code.nil?
        raise UnexpectedJSON, "Unexpected JSON from forecast API"
      end

      Report.new(
        place: place,
        temperature_c: Float(temperature),
        apparent_c: Float(apparent),
        weather_code: Integer(code),
        conditions: Codes.label(code)
      )
    rescue ArgumentError, TypeError
      raise UnexpectedJSON, "Unexpected JSON from forecast API"
    end

    def self.format_report(report)
      location = [report.place.name, report.place.admin1, report.place.country].compact.reject(&:empty?).uniq.join(", ")
      format(
        "%<location>s\n%<temp>.1f °C (feels like %<apparent>.1f °C)\n%<conditions>s\n",
        location: location,
        temp: report.temperature_c,
        apparent: report.apparent_c,
        conditions: report.conditions
      )
    end

    private

    def geocode(city)
      self.class.parse_place(fetch_json(geocode_url(city)), city)
    end

    def geocode_url(city)
      query = URI.encode_www_form(name: city, count: 1, language: "pt", format: "json")
      "#{GEOCODE_URL}?#{query}"
    end

    def forecast_url(place)
      query = URI.encode_www_form(
        latitude: place.latitude,
        longitude: place.longitude,
        current: "temperature_2m,apparent_temperature,weather_code",
        timezone: "auto"
      )
      "#{FORECAST_URL}?#{query}"
    end

    def fetch_json(url)
      payload = @get ? @get.call(url) : default_get(url)
      payload.is_a?(String) ? JSON.parse(payload) : payload
    rescue JSON::ParserError
      raise UnexpectedJSON, "Unexpected JSON from weather API"
    end

    def default_get(url)
      uri = URI(url)
      response = Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == "https",
        open_timeout: TIMEOUT,
        read_timeout: TIMEOUT
      ) do |http|
        http.get(uri.request_uri, { "User-Agent" => "weather-assist" })
      end
      unless response.is_a?(Net::HTTPSuccess)
        raise NetworkError, "Network error: HTTP #{response.code}"
      end

      response.body
    rescue Error
      raise
    rescue StandardError => e
      raise NetworkError, "Network error: #{e.message}"
    end
  end
end
