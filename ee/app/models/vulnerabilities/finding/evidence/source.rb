# frozen_string_literal: true

module Vulnerabilities
  class Finding
    class Evidence
      class Source < ApplicationRecord
        include AnyFieldValidation

        self.table_name = 'vulnerability_finding_evidence_sources'

        DATA_FIELDS = %w[name url].freeze

        belongs_to :evidence, class_name: 'Vulnerabilities::Finding::Evidence', inverse_of: :source, foreign_key: 'vulnerability_finding_evidence_id', optional: false

        validates :name, length: { maximum: 2048 }
        validates :url, length: { maximum: 2048 }

        validate :any_field_present

        private

        def one_of_required_fields
          DATA_FIELDS
        end
      end
    end
  end
end
