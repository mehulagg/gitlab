# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module UpdateLocationFingerprintForContainerScanningFindings
        extend ::Gitlab::Utils::Override

        module UUID
          NAMESPACE_IDS = {
            development: "a143e9e2-41b3-47bc-9a19-081d089229f4",
            test: "a143e9e2-41b3-47bc-9a19-081d089229f4",
            staging: "a6930898-a1b2-4365-ab18-12aa474d9b26",
            production: "58dc0f06-936c-43b3-93bb-71693f1b6570"
          }.freeze

          UUID_V5_PATTERN = /\h{8}-\h{4}-5\h{3}-\h{4}-\h{4}\h{8}/.freeze
          NAMESPACE_REGEX = /(\h{8})-(\h{4})-(\h{4})-(\h{4})-(\h{4})(\h{8})/.freeze
          PACK_PATTERN = "NnnnnN"

          class << self
            def v5(name, namespace_id: default_namespace_id)
              Digest::UUID.uuid_v5(namespace_id, name)
            end

            private

            def default_namespace_id
              @default_namespace_id ||= begin
                namespace_uuid = NAMESPACE_IDS.fetch(Rails.env.to_sym)
                # Digest::UUID is broken when using a UUID as a namespace_id
                # https://github.com/rails/rails/issues/37681#issue-520718028
                namespace_uuid.scan(NAMESPACE_REGEX).flatten.map { |s| s.to_i(16) }.pack(PACK_PATTERN)
              end
            end
          end
        end

        class Identifier < ActiveRecord::Base
          include ::EachBatch

          self.table_name = 'vulnerability_identifiers'
        end

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

          def calculate_new_uuid(fingerprint)
            primary_identifier = Identifier.select(:fingerprint).where(id: primary_identifier_id).first
            return if primary_identifier.nil?

            parts = [
              report_type,
              primary_identifier.fingerprint,
              fingerprint,
              project_id
            ]

            UUID.v5(parts.join('-'))
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
            .select(:id, "raw_metadata::json->'location' AS loc", :report_type, :project_id, :primary_identifier_id)
                  .where(id: start_id..stop_id)
                  .each do |finding|
                    next if finding.loc.nil?

                    package = finding.loc.dig('dependency', 'package', 'name')
                    image = finding.loc.dig('image')

                    new_fingerprint = finding.calculate_new_fingerprint(image, package)
                    next if new_fingerprint.blank?

                    new_uuid = finding.calculate_new_uuid(new_fingerprint)
                    next if new_uuid.blank?

                    begin
                      finding.update_columns(location_fingerprint: new_fingerprint, uuid: new_uuid)
                    rescue ActiveRecord::RecordNotUnique
                      ::Gitlab::BackgroundMigration::Logger.warn("Duplicate finding found with finding id #{finding.id}")
                    end
                  end
        end
      end
    end
  end
end
