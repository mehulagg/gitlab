# frozen_string_literal: true

module Vulnerabilities
  class FindingFingerprint < ApplicationRecord
    self.table_name = 'vulnerability_finding_fingerprints'

    include BulkInsertSafe

    belongs_to :finding, foreign_key: 'finding_id', inverse_of: :fingerprints, class_name: 'Vulnerabilities::Finding'

    enum algorithm_type: { hash: 1, location: 2, scope_offset: 3 }, _prefix: :algorithm

    validates :finding, presence: true
  end
end
