# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        module Formatters
          class ContainerScanning
            def initialize(vulnerability)
              @vulnerability = vulnerability
            end

            def format(image)
              {
                'category' => 'container_scanning',
                'message' => message,
                'description' => description,
                'cve' => vulnerability['vulnerability'],
                'severity' => translate_severity,
                'solution' => solution,
                'confidence' => 'Medium',
                'location' => {
                  'image' => image,
                  'operating_system' => vulnerability["namespace"],
                  'dependency' => {
                    'package' => {
                      'name' => vulnerability["featurename"]
                    },
                    'version' => vulnerability["featureversion"]
                  }
                },
                'scanner' => { 'id' => 'clair', 'name' => 'Clair' },
                'identifiers' => [
                  {
                    'type' => 'cve',
                    'name' => vulnerability['vulnerability'],
                    'value' => vulnerability['vulnerability'],
                    'url' => vulnerability['link']
                  }
                ],
                'links' => [{ 'url' => vulnerability['link'] }]
              }
            end

            private

            attr_reader :vulnerability

            def message
              format_definitions(
                %w[vulnerability featurename] => '%{vulnerability} in %{featurename}',
                'vulnerability' => '%{vulnerability}'
              )
            end

            def description
              format_definitions(
                'description' => '%{description}',
                %w[featurename featureversion] => '%{featurename}:%{featureversion} is affected by %{vulnerability}',
                'featurename' => '%{featurename} is affected by %{vulnerability}',
                'namespace' => '%{namespace} is affected by %{vulnerability}'
              )
            end

            def translate_severity
              severity = vulnerability['severity']

              case severity
              when 'Negligible'
                'low'
              when 'Unknown', 'Low', 'Medium', 'High', 'Critical'
                severity.downcase
              when 'Defcon1'
                'critical'
              else
                safe_severity = ERB::Util.html_escape(severity)
                raise(
                  ::Gitlab::Ci::Parsers::Security::Common::SecurityReportParserError,
                  "Unknown severity in container scanning report: #{safe_severity}"
                )
              end
            end

            def solution
              format_definitions(
                %w[fixedby featurename featureversion] => 'Upgrade %{featurename} from %{featureversion} to %{fixedby}',
                %w[fixedby featurename] => 'Upgrade %{featurename} to %{fixedby}',
                'fixedby' => 'Upgrade to %{fixedby}'
              )
            end

            def format_definitions(definitions)
              definitions.find do |keys, value|
                vulnerability.values_at(*keys).all?(&:present?)
              end.then do |_, value|
                if value.present?
                  value % vulnerability.symbolize_keys
                end
              end
            end
          end
        end
      end
    end
  end
end
