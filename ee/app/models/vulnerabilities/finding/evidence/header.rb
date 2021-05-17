# frozen_string_literal: true

module Vulnerabilities
  class Finding
    class Evidence
      class Header < ApplicationRecord
        self.table_name = 'vulnerability_finding_evidence_headers'

        belongs_to :request, class_name: 'Vulnerabilities::Finding::Evidence::Request', inverse_of: :headers, foreign_key: 'vulnerability_finding_evidence_request_id'
        belongs_to :response, class_name: 'Vulnerabilities::Finding::Evidence::Response', inverse_of: :headers, foreign_key: 'vulnerability_finding_evidence_response_id'

        validates :name, length: { maximum: 255 }
        validate :belongs_to_either_response_or_request

        def belongs_to_either_response_or_request
          errors.add(:header, "must belong to either request or response") unless request.present? ^ response.present?
        end
      end
    end
  end
end
