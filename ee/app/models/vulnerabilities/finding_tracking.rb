# frozen_string_literal: true

module Vulnerabilities
  class FindingTracking < ApplicationRecord
    self.table_name = 'vulnerability_finding_trackings'

    include BulkInsertSafe

    belongs_to :finding, foreign_key: 'finding_id', inverse_of: :trackings, class_name: 'Vulnerabilities::Finding'

    enum algorithm_type: { hash: 1, location: 2, scope_offset: 3 }, _prefix: :algorithm

    validates :finding, presence: true
  end
end
