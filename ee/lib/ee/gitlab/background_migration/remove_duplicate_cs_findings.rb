# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module RemoveDuplicateCsFindings
        extend ::Gitlab::Utils::Override

        class Finding < ActiveRecord::Base
          include ::ShaAttribute
          include ::EachBatch

          BROKEN_FINGERPRINT_LENGTH = 40

          belongs_to :vulnerability, class_name: 'Vulnerability'

          self.table_name = 'vulnerability_occurrences'

          REPORT_TYPES = {
            container_scanning: 2
          }.with_indifferent_access.freeze

          enum report_type: REPORT_TYPES

          sha_attribute :location_fingerprint
        end

        class Note < ActiveRecord::Base; end

        class Vulnerability < ActiveRecord::Base
          has_many :findings, class_name: 'Finding', inverse_of: :vulnerability
          has_many :notes, class_name: 'Note', foreign_key: 'noteable_id'

          def delete_notes
            Note.where(project_id: project_id, noteable_type: 'Vulnerability', noteable_id: id).delete_all
          end
        end

        override :perform
        def perform(start_id, stop_id)
          Finding.select(:id, :project_id, :primary_identifier_id, :location_fingerprint, :scanner_id)
            .container_scanning
            .where(id: start_id..stop_id)
            .where("length(location_fingerprint) = ?", Finding::BROKEN_FINGERPRINT_LENGTH)
            .each do |finding|
              colliding_fingerprint = ::Gitlab::Database::ShaAttribute.new.serialize(finding.location_fingerprint).to_s
              duplicated_finding = Finding.container_scanning.where(project_id: finding.project_id,
                                                primary_identifier_id: finding.primary_identifier_id,
                                                scanner_id: finding.scanner_id,
                                                location_fingerprint: colliding_fingerprint).first

              next if duplicated_finding.blank?
              # we have some findings without vulnerabilities
              next if duplicated_finding.vulnerability.nil?

              ActiveRecord::Base.transaction do
                duplicated_finding.vulnerability.delete_notes
                duplicated_finding.vulnerability.delete
                duplicated_finding.delete

                # update can be done without violating unique constraint
                # index_vulnerability_occurrences_on_unique_keys
                # since we included sha_attribute :location_fingerprint it will be updated in correct format
                finding.update(location_fingerprint: colliding_fingerprint)
              end
            end
        end
      end
    end
  end
end
