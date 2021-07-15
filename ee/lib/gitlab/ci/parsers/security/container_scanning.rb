# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        class ContainerScanning < Common
          private

          def create_location(location_data)
            ::Gitlab::Ci::Reports::Security::Locations::ContainerScanning.new(
              image: location_data['image'],
              operating_system: location_data['operating_system'],
              package_name: location_data.dig('dependency', 'package', 'name'),
              package_version: location_data.dig('dependency', 'version'),
              base_image: base_image(location_data)
            )
          end

          def base_image(location_data)
            return if @job.nil? || @report.pipeline.default_branch?

            # TODO: Check if base_image exists in vulnerability_occurrences table
            location_data['base_image']
          end
        end
      end
    end
  end
end
