# frozen_string_literal: true

module Vulnerabilities
  class Findings
    class Evidences
      class Header < ApplicationRecord
        self.table_name = 'vulnerability_finding_evidence_headers'

        belongs_to :request, class_name: 'Vulnerabilities::Findings::Evidences::Request', inverse_of: :headers, foreign_key: 'vulnerability_finding_evidence_request_id', optional: true
        belongs_to :response, class_name: 'Vulnerabilities::Findings::Evidences::Response', inverse_of: :headers, foreign_key: 'vulnerability_finding_evidence_response_id', optional: true
      end
    end
  end
end
