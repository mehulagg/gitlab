# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Metrics
        class Generic
          MetricsParserError = Class.new(::Gitlab::Ci::Parsers::ParserError)

          def parse!(string_data, metrics_report)
            string_data.each_line.lazy.reject(&:blank?).each { |line| parse_line(line, metrics_report) }
          end

          private

          def parse_line(line, metrics_report)
            name, *metric_values = line.gsub(/#.*$/, '').shellsplit
            return if name.blank? || metric_values.empty?

            metrics_report.add_metric(name, metric_values.first)
          rescue StandardError => e
            Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e)
            raise MetricsParserError, "Metrics parsing failed"
          end
        end
      end
    end
  end
end
