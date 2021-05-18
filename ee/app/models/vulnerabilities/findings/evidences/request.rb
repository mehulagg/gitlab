# frozen_string_literal: true

module Vulnerabilities
  class Findings
    class Evidences
      class Request < ApplicationRecord
        self.table_name = 'vulnerability_finding_evidence_requests'

        belongs_to :evidence, class_name: 'Vulnerabilities::Findings::Evidence', inverse_of: :request, foreign_key: 'vulnerability_finding_evidence_id', optional: false

        validates :method, length: { maximum: 32 }
        validates :url, length: { maximum: 2048 }
        validates :body, length: { maximum: 2048 }
      end
    end
  end
end
