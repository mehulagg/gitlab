# frozen_string_literal: true

module Vulnerabilities
  class Finding
    class Evidence
      class SupportingMessage < ApplicationRecord
        self.table_name = 'vulnerability_finding_evidence_supporting_messages'

        belongs_to :evidence, class_name: 'Vulnerabilities::Finding::Evidence', inverse_of: :supporting_message, foreign_key: 'vulnerability_finding_evidence_id', optional: false

        validates :name, length: { maximum: 2048 }, presence: true
      end
    end
  end
end
