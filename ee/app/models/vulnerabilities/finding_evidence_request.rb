# frozen_string_literal: true

module Vulnerabilities
  class FindingEvidenceRequest < ApplicationRecord
    self.table_name = 'vulnerability_finding_evidence_requests'

    belongs_to :finding_evidence, class_name: 'Vulnerabilities::FindingEvidence', inverse_of: :requests, foreign_key: 'vulnerability_finding_evidence_id', optional: false
    has_many :headers, class_name: 'Vulnerabilities::Findings::Evidences::Header', inverse_of: :request, foreign_key: 'vulnerability_finding_evidence_request_id'
  end
end
