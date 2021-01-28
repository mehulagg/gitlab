# frozen_string_literal: true

module Gitlab
  module Usage
    class MetricDefinition
      METRIC_SCHEMA_PATH = Rails.root.join('config', 'metrics', 'schema.json')

      attr_reader :path
      attr_reader :attributes

      def initialize(path, opts = {})
        @path = path
        @attributes = opts
      end

      def to_h
        attributes
      end

      def validate!
        unless skip_validation?
          self.class.schemer.validate(attributes.stringify_keys).each do |error|
            Gitlab::ErrorTracking.track_and_raise_for_dev_exception(Metric::InvalidMetricError.new("#{error["details"] || error['data_pointer']} for `#{path}`"))
          end
        end
      end

      alias_method :to_dictionary, :to_h

      private

      def method_missing(method, *args)
        attributes[method] || super
      end

      def skip_validation?
        !!attributes[:skip_validation]
      end

      def self.schemer
        @schemer ||= ::JSONSchemer.schema(Pathname.new(METRIC_SCHEMA_PATH))
      end
    end
  end
end
