# frozen_string_literal: true

module Vulnerabilities
  class Finding
    class Evidence
      class SupportingMessage < ApplicationRecord
        self.table_name = 'vulnerability_finding_evidence_sources'

        belongs_to :evidence, class_name: 'Vulnerabilities::Finding::Evidence', inverse_of: :supporing_message, foreign_key: 'vulnerability_finding_evidence_id', optional: false

        validates :name, length: { maximum: 2048 }
      end
    end
  end
end
