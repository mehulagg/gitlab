# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        module Concerns
          module DeprecatedSyntax
            extend ActiveSupport::Concern

            included do
              extend ::Gitlab::Utils::Override

              override :parse_report
            end

            def parse_report(json_data)
              report = super

              if report.is_a?(Array)
                report = {
                  "version" => self.class::DEPRECATED_REPORT_VERSION,
                  "vulnerabilities" => report
                }
              end

              report
            end
          end
        end
      end
    end
  end
end
