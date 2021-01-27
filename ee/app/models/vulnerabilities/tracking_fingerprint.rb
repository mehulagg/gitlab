# frozen_string_literal: true

module Vulnerabilities
  class TrackingFingerprint < ApplicationRecord
    self.table_name = 'vulnerability_tracking_fingerprints'

    belongs_to :finding, foreign_key: 'finding_id', inverse_of: :tracking_fingerprints, class_name: 'Vulnerabilities::Finding'

    enum track_type: { legacy: 0, hash: 1, source: 1 }, _prefix: true
    enum track_method: { legacy: 0, hash: 1, location: 2, scope_offset: 3 }, _prefix: :method
    enum priority: {
        legacy: 0,
        # hash type: [0-1000)
        hash_hash: 1,
        # source type: [1000-2000)
        source_location: 1000,
        source_scope_offset: 1100
    }, _prefix: true

    validates :finding, presence: true

    def type_key
      "#{track_type_raw}:#{track_method_raw}"
    end

    def same_type?(other)
      other.track_type == track_type && other.track_method == track_method
    end

    def types_comparable?(other)
      other.track_type_raw == self.class.track_types[:legacy] ||
        track_type_raw == self.class.track_types[:legacy] ||
        same_type?(other)
    end

    def ==(other)
      other.sha == sha
    end

    # easy access to integer value
    def priority_raw
      self.class.priorities[priority]
    end

    # easy access to integer value
    def track_type_raw
      self.class.track_types[track_type]
    end

    # easy access to integer value
    def track_method_raw
      self.class.track_methods[track_method]
    end
  end
end
