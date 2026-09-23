# frozen_string_literal: true

require "optparse"
require_relative "client"

module WeatherAssist
  class CLI
    USAGE = <<~TEXT
      Usage: weather-assist now [--city CITY] [CITY]

      Show the current temperature for a city via Open-Meteo.
    TEXT

    def self.start(argv, client: Client.new, out: $stdout, err: $stderr)
      new(argv, client: client, out: out, err: err).run
    end

    def initialize(argv, client:, out:, err:)
      @argv = argv.dup
      @client = client
      @out = out
      @err = err
    end

    def run
      command = @argv.shift
      case command
      when "now"
        now(@argv)
      when "-h", "--help", "help"
        @out.puts USAGE
        0
      else
        @err.puts command.nil? ? "Command is required" : "Unknown command: #{command}"
        @err.puts USAGE
        1
      end
    end

    private

    def now(args)
      city = nil
      parser = OptionParser.new do |opts|
        opts.on("--city CITY", String) { |value| city = value }
      end
      parser.parse!(args)
      city ||= args.shift
      if city.nil? || city.strip.empty?
        @err.puts "City is required"
        @err.puts USAGE
        return 1
      end
      unless args.empty?
        @err.puts "Unexpected argument: #{args.first}"
        return 1
      end

      report = @client.current(city.strip)
      @out.print Client.format_report(report)
      0
    rescue OptionParser::ParseError => e
      @err.puts e.message
      1
    rescue Error => e
      @err.puts e.message
      1
    end
  end
end
