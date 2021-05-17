# frozen_string_literal: true

module Vulnerabilities
  class Findings
    class Evidences
      class Response < ApplicationRecord
        self.table_name = 'vulnerability_finding_evidence_responses'

        belongs_to :evidence, class_name: 'Vulnerabilities::Findings::Evidence', inverse_of: :response, foreign_key: 'vulnerability_finding_evidence_id', optional: false

        validates :reason_phrase, length: { maximum: 2048 }
        validates :body, length: { maximum: 2048 }
      end
    end
  end
end
