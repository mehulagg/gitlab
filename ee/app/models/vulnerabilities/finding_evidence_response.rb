# frozen_string_literal: true

module Vulnerabilities
  class FindingEvidenceResponse < ApplicationRecord
    self.table_name = 'vulnerability_finding_evidence_responses'

    belongs_to :finding_evidence, class_name: 'Vulnerabilities::FindingEvidence', inverse_of: :responses, foreign_key: 'vulnerability_finding_evidence_id', optional: false
    has_many :headers, class_name: 'Vulnerabilities::Findings::Evidences::Header', inverse_of: :response, foreign_key: 'vulnerability_finding_evidence_response_id'
  end
end
