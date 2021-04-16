# frozen_string_literal: true

module Vulnerabilities
  class FindingEvidenceResponse < ApplicationRecord
    self.table_name = 'vulnerability_finding_evidence_responses'

    belongs_to :finding_evidence, class_name: 'Vulnerabilities::FindingEvidence', inverse_of: :finding_evidence_responses, foreign_key: 'vulnerability_finding_evidences_id', optional: false
  end
end
