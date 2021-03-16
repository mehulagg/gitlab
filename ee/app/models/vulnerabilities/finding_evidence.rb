# frozen_string_literal: true

module Vulnerabilities
  class FindingEvidence < ApplicationRecord
    self.table_name = 'vulnerability_finding_evidences'

    belongs_to :finding, foreign_key: 'finding_id', inverse_of: :evidences, class_name: 'Vulnerabilities::Finding'

    validates :finding, presence: true
  end
end
