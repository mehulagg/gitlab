# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        class ContainerScanning < Common
          include Security::Concerns::DeprecatedSyntax

          DEPRECATED_REPORT_VERSION = "1.3".freeze

          def parse!(json_data, report)
            vulnerabilities = format_report(JSON.parse!(json_data))

            vulnerabilities.each do |vulnerability|
              create_vulnerability(report, vulnerability, DEPRECATED_REPORT_VERSION)
            end
          rescue JSON::ParserError
            raise SecurityReportParserError, 'JSON parsing failed'
          rescue
            raise SecurityReportParserError, "#{report.type} security report parsing failed"
          end

          private

          # Transforms the Clair JSON report into the expected format
          def format_report(data)
            vulnerabilities = data['vulnerabilities']
            unapproved = data['unapproved']
            results = []

            vulnerabilities.each do |vulnerability|
              # We only report unapproved vulnerabilities
              next unless unapproved.include?(vulnerability['vulnerability'])

              results.append(format_vulnerability(vulnerability, data['image']))
            end

            results
          end

          def format_vulnerability(vulnerability, image)
            Formatters::ContainerScanning.new(vulnerability).format(image)
          end

          def create_location(location_data)
            ::Gitlab::Ci::Reports::Security::Locations::ContainerScanning.new(
              image: location_data['image'],
              operating_system: location_data['operating_system'],
              package_name: location_data.dig('dependency', 'package', 'name'),
              package_version: location_data.dig('dependency', 'version'))
          end
        end
      end
    end
  end
end
