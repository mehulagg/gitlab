# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module LicenseCompliance
        class LicenseScanning
          LicenseScanningParserError = Class.new(Gitlab::Ci::Parsers::ParserError)
          DEFAULT_VERSION = '1.0'
          PARSERS = { '1' => V1, '2' => V2 }.freeze

          def parse!(json_data, report)
            json = Gitlab::Json.parse(json_data, symbolize_names: true, object_class: Hash)
            return unless json.is_a?(Hash)

            report.version = json[:version].presence || DEFAULT_VERSION

            parser = PARSERS.fetch(report.major_version)
            parser.new(report).parse(json)
          rescue JSON::ParserError => error
            Gitlab::ErrorTracking.track_exception(error, error_details_for(json_data))
          end

          private

          def error_details_for(json)
            return { message: 'artifact is blank' } if json.blank?
            return { message: "artifact is too big (#{json.bytesize} bytes)" } if json.bytesize > 1.megabyte

            { message: 'artifact is not JSON', raw: json }
          end
        end
      end
    end
  end
end
