# frozen_string_literal: true

# This model represents the vulnerability findings
# discovered for all pipelines to use in pipeline
# security tab.
#
# Unlike `Vulnerabilities::Finding` model, this one
# only stores some important meta information to
# calculate which report artifact to download and parse.
module Security
  class Finding < ApplicationRecord
    self.table_name = 'security_findings'

    belongs_to :scan, inverse_of: :findings, optional: false
    belongs_to :scanner, class_name: 'Vulnerabilities::Scanner', inverse_of: :security_findings, optional: false

    # TODO: These are duplicated between this model and Vulnerabilities::Finding,
    # we should create a shared module to encapculate this in one place.
    enum confidence: Vulnerabilities::Finding::CONFIDENCE_LEVELS, _prefix: :confidence
    enum severity: Vulnerabilities::Finding::SEVERITY_LEVELS, _prefix: :severity

    validates :project_fingerprint, presence: true, length: { maximum: 40 }
    validates :position, presence: true

    scope :by_position, -> (positions) { where(position: positions) }
    scope :by_build_ids, -> (build_ids) { joins(scan: :build).where(ci_builds: { id: build_ids }) }
  end
end
