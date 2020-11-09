# frozen_string_literal: true

module Vulnerabilities
  class TrackingFingerprint < ApplicationRecord
    self.table_name = 'vulnerability_tracking_fingerprints'

    belongs_to :vulnerability_occurrences

    enum type: { hash: 0, source: 1 }, prefix: 'type_'
    enum method: { hash: 0, location: 1, scope_offset: 2 }, prefix: 'method_'
    enum priority: {
        # hash type: [0-1000)
        hash_hash: 0,
        # source type: [1000-2000)
        source_location: 1000,
        source_scope_offset: 1100,
      }, prefix: 'priority_'

    validates :finding, presence: true
  end
end
