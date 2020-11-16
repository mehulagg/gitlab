# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Codequality
        class CodeClimate
          def parse!(json_data, codequality_report)
            root = Gitlab::Json.parse(json_data)

            parse_all(root, codequality_report)
          rescue JSON::ParserError => e
            codequality_report.set_error_message("JSON parsing failed: #{e}")
          rescue StandardError => e
            codequality_report.set_error_message("CodeClimate parsing failed: #{e}")
          end

          private

          def parse_all(root, codequality_report)
            return unless root.present?

            root.each do |degredation|
              codequality_report.add_degredation(degredation.dig('fingerprint'), degredation)
            end

            codequality_report
          end
        end
      end
    end
  end
end
