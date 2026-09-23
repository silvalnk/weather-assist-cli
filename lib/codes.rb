# frozen_string_literal: true

module WeatherAssist
  module Codes
    LABELS = {
      0 => "Clear",
      1 => "Mainly clear",
      2 => "Partly cloudy",
      3 => "Overcast",
      45 => "Fog",
      48 => "Rime fog",
      51 => "Drizzle",
      53 => "Drizzle",
      55 => "Drizzle",
      56 => "Freezing drizzle",
      57 => "Freezing drizzle",
      61 => "Rain",
      63 => "Rain",
      65 => "Rain",
      66 => "Freezing rain",
      67 => "Freezing rain",
      71 => "Snow",
      73 => "Snow",
      75 => "Snow",
      77 => "Snow grains",
      80 => "Rain showers",
      81 => "Rain showers",
      82 => "Rain showers",
      85 => "Snow showers",
      86 => "Snow showers",
      95 => "Thunderstorm",
      96 => "Thunderstorm",
      99 => "Thunderstorm"
    }.freeze

    def self.label(code)
      LABELS.fetch(Integer(code)) { "Unknown" }
    rescue ArgumentError, TypeError
      "Unknown"
    end
  end
end
