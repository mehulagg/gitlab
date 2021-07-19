# frozen_string_literal: true

module Vulnerabilities
  class Finding
    class Evidence
      class Request < ApplicationRecord
        include WithBody
        include AnyFieldValidation

        self.table_name = 'vulnerability_finding_evidence_requests'

        DATA_FIELDS = %w[method url].freeze

        belongs_to :evidence, class_name: 'Vulnerabilities::Finding::Evidence', inverse_of: :request, foreign_key: 'vulnerability_finding_evidence_id', optional: false
        has_many :headers, class_name: 'Vulnerabilities::Finding::Evidence::Header', inverse_of: :request, foreign_key: 'vulnerability_finding_evidence_request_id'

        validates :method, length: { maximum: 32 }
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
