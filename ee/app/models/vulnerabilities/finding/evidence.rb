# frozen_string_literal: true

module Vulnerabilities
  class Finding
    class Evidence < ApplicationRecord
      self.table_name = 'vulnerability_finding_evidences'

      belongs_to :finding, class_name: 'Vulnerabilities::Finding', inverse_of: :evidence, foreign_key: 'vulnerability_occurrence_id', optional: false

      validates :summary, length: { maximum: 8_000_000 }
    end
  end
end
