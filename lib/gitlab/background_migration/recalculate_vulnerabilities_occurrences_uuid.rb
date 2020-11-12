# frozen_string_literal: true

# rubocop: disable Style/Documentation
class Gitlab::BackgroundMigration::RecalculateVulnerabilitiesOccurrencesUuid
  class VulnerabilitiesIdentifier < ActiveRecord::Base
    self.table_name = "vulnerability_identifiers"
    has_many :primary_findings, class_name: 'VulnerabilitiesFinding', inverse_of: :primary_identifier, foreign_key: 'primary_identifier_id'
  end

  class VulnerabilitiesFinding < ActiveRecord::Base
    self.table_name = "vulnerability_occurrences"
    belongs_to :primary_identifier, class_name: 'VulnerabilitiesIdentifier', inverse_of: :primary_findings, foreign_key: 'primary_identifier_id'
    REPORT_TYPES = {
      sast: 0,
      dependency_scanning: 1,
      container_scanning: 2,
      dast: 3,
      secret_detection: 4,
      coverage_fuzzing: 5,
      api_fuzzing: 6
    }.with_indifferent_access.freeze
    enum report_type: REPORT_TYPES
  end

  def perform(finding_id)
    vulnerability_finding = VulnerabilitiesFinding.includes(:primary_identifier).find(finding_id)

    return unless vulnerability_finding

    uuid_v5_name_components = {
      report_type: vulnerability_finding.report_type,
      primary_identifier_fingerprint: vulnerability_finding.primary_identifier.fingerprint,
      location_fingerprint: vulnerability_finding.location_fingerprint,
      project_id: vulnerability_finding.project_id
    }

    name = uuid_v5_name_components.values.join('-')

    uuid_v5 = Gitlab::Vulnerabilities::CalculateFindingUUID.call(name)

    vulnerability_finding.update(uuid: uuid_v5) if uuid_v5
  end
end
