# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require "cli"

class ClientTest < Minitest::Test
  def setup
    @place_payload = {
      "results" => [
        {
          "name" => "São Paulo",
          "admin1" => "São Paulo",
          "country" => "Brazil",
          "latitude" => -23.55,
          "longitude" => -46.63
        }
      ]
    }
    @forecast_payload = {
      "current" => {
        "temperature_2m" => 22.4,
        "apparent_temperature" => 21.1,
        "weather_code" => 0
      }
    }
  end

  def test_parse_place
    place = WeatherAssist::Client.parse_place(@place_payload, "São Paulo")

    assert_equal "São Paulo", place.name
    assert_equal "Brazil", place.country
    assert_in_delta(-23.55, place.latitude)
  end

  def test_missing_city
    error = assert_raises(WeatherAssist::CityNotFound) do
      WeatherAssist::Client.parse_place({ "results" => [] }, "Nowhere")
    end

    assert_equal "City not found: Nowhere", error.message
  end

  def test_unexpected_geocode_json
    assert_raises(WeatherAssist::UnexpectedJSON) do
      WeatherAssist::Client.parse_place({ "error" => true }, "São Paulo")
    end
  end

  def test_parse_report
    place = WeatherAssist::Client.parse_place(@place_payload, "São Paulo")
    report = WeatherAssist::Client.parse_report(@forecast_payload, place)

    assert_in_delta 22.4, report.temperature_c
    assert_in_delta 21.1, report.apparent_c
    assert_equal "Clear", report.conditions
  end

  def test_weather_codes
    assert_equal "Clear", WeatherAssist::Codes.label(0)
    assert_equal "Rain", WeatherAssist::Codes.label(61)
    assert_equal "Snow", WeatherAssist::Codes.label(73)
    assert_equal "Thunderstorm", WeatherAssist::Codes.label(95)
    assert_equal "Unknown", WeatherAssist::Codes.label(123)
  end

  def test_current_uses_injected_get
    calls = []
    client = WeatherAssist::Client.new(get: lambda { |url|
      calls << url
      url.include?("search") ? @place_payload : @forecast_payload
    })

    report = client.current("São Paulo")

    assert_equal 2, calls.length
    assert_match(/name=S%C3%A3o\+Paulo/, calls[0])
    assert_match(/latitude=-23\.55/, calls[1])
    assert_equal "Clear", report.conditions
  end

  def test_cli_prints_report_without_network
    client = WeatherAssist::Client.new(get: lambda { |url|
      url.include?("search") ? @place_payload : @forecast_payload
    })
    out = StringIO.new
    err = StringIO.new

    status = WeatherAssist::CLI.start(["now", "São Paulo"], client: client, out: out, err: err)

    assert_equal 0, status
    assert_equal "São Paulo, Brazil\n22.4 °C (feels like 21.1 °C)\nClear\n", out.string
    assert_empty err.string
  end

  def test_cli_requires_city
    err = StringIO.new

    status = WeatherAssist::CLI.start(["now"], out: StringIO.new, err: err)

    assert_equal 1, status
    assert_match(/City is required/, err.string)
  end
end
