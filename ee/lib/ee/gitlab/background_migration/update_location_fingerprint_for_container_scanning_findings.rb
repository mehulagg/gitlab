# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module UpdateLocationFingerprintForContainerScanningFindings
        extend ::Gitlab::Utils::Override

        class Finding < ActiveRecord::Base
          include ::ShaAttribute
          include ::EachBatch

          self.table_name = 'vulnerability_occurrences'

          REPORT_TYPES = {
            container_scanning: 2
          }.with_indifferent_access.freeze

          enum report_type: REPORT_TYPES

          sha_attribute :location_fingerprint

          # Copied from Reports::Security::Locations
          def calculate_new_fingerprint(image, package_name)
            return if image.nil? || package_name.nil?

            Digest::SHA1.hexdigest("#{docker_image_name_without_tag(image)}:#{package_name}")
          end

          private

          def docker_image_name_without_tag(image)
            base_name, version = image.split(':')

            return image if version_semver_like?(version)

            base_name
          end

          def version_semver_like?(version)
            hash_like = /\A[0-9a-f]{32,128}\z/i

            if Gem::Version.correct?(version)
              !hash_like.match?(version)
            else
              false
            end
          end
        end

        override :perform
        def perform(start_id, stop_id)
          Finding.container_scanning
                  .select(:id, "raw_metadata::json->'location' AS loc")
                  .where(id: start_id..stop_id)
                  .each do |finding|
                    next if finding.loc.nil?

                    package = finding.loc.dig('dependency', 'package', 'name')
                    image = finding.loc.dig('image')
                    new_fingerprint = finding.calculate_new_fingerprint(image, package)

                    next if new_fingerprint.blank?

                    begin
                      finding.update_column(:location_fingerprint, new_fingerprint)
                    rescue ActiveRecord::RecordNotUnique
                      ::Gitlab::BackgroundMigration::Logger.warn("Duplicate finding found with finding id #{finding.id}")
                    end
                  end
        end
      end
    end
  end
end
