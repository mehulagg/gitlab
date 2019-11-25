# frozen_string_literal: true

module Metrics
  class SampleMetricsService
    DIRECTORY = "sample_metrics"

    MissingSampleMetricsFile = Class.new(StandardError)

    attr_reader :identifier, :range_minutes

    def initialize(identifier, range)
      @identifier = identifier
      @range_minutes = ((range[:end_range].to_time - range[:start_range].to_time) / 1.minute).to_i
    end

    def query
      raise MissingSampleMetricsFile unless File.exist?(file_location)

      query_interval
    end

    private

    def file_location
      File.join(Rails.root, 'sample_metrics', "#{identifier}.yml")
    end

    def query_interval
      result = YAML.load_file(File.expand_path(file_location, __dir__))
      result[range_minutes]
    end
  end
end
