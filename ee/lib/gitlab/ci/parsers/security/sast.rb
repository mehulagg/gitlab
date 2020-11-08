# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        class Sast < Common
          include Security::Concerns::DeprecatedSyntax

          DEPRECATED_REPORT_VERSION = "1.2".freeze

          private

          def create_location(location_data, report)
            ::Gitlab::Ci::Reports::Security::Tracking::Source.highest_supported(
              location_data['file'],
              location_data['start_line'],
              location_data['end_line'],
            ).new(
              report.pipeline.project.repository,
              report.pipeline.sha,
              location_data['file'],
              location_data['start_line'],
              location_data['end_line'],
            )
          end
        end
      end
    end
  end
end
