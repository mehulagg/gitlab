# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        class Dast < Common
          protected

          def parse_report(json_data)
            report = super

            return Formatters::Dast.new(report).format if Formatters::Dast.satisfies?(report)

            report
          end

          private

          def create_location(location_data)
            ::Gitlab::Ci::Reports::Security::Locations::Dast.new(
              hostname: location_data['hostname'],
              method_name: location_data['method'],
              param: location_data['param'],
              path: location_data['path'])
          end
        end
      end
    end
  end
end
