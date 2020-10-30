# frozen_string_literal: true

module Vulnerabilities
  class FindingLink < ApplicationRecord
    self.table_name = 'vulnerability_finding_links'

    alias_attribute :finding_id, :vulnerability_occurrence_id

    belongs_to :finding, class_name: 'Vulnerabilities::Finding', inverse_of: :finding_identifiers, foreign_key: 'vulnerability_occurrence_id'

    validates :finding, presence: true
    validates :url, presence: true
  end
end
