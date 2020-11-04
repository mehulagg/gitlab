# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module CodeQuality
        class CodeClimate
          def parse!(json_data, codequality_report)
            root = Gitlab::Json.parse(json_data).with_indifferent_access

            parse_all(root, codequality_report)
          # rescue JSON::ParserError => e
          #   accessibility_report.set_error_message("JSON parsing failed: #{e}")
          # rescue StandardError => e
          #   accessibility_report.set_error_message("Pa11y parsing failed: #{e}")
          end

          private

          def parse_all(root, codequality_report)
            return unless root.present?

            # root.dig("results").each do |url, value|
            #   codequality_report.add_url(url, value)
            # end

            # codequality_report
          end
        end
      end
    end
  end
end
