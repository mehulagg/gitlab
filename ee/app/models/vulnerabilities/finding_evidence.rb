# frozen_string_literal: true

module Vulnerabilities
  class FindingEvidence < ApplicationRecord
    self.table_name = 'vulnerability_finding_evidences'

    belongs_to :finding, class_name: 'Vulnerabilities::Finding', inverse_of: :finding_evidences, foreign_key: 'vulnerability_occurrence_id', optional: false

    has_many :finding_evidence_responses, class_name: 'Vulnerabilities::FindingEvidenceResponse', inverse_of: :finding_evidence, foreign_key: 'vulnerability_finding_evidences_id'
  end
end
