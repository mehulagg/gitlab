# frozen_string_literal: true

module Vulnerabilities
  class FindingSignature < ApplicationRecord
    self.table_name = 'vulnerability_finding_signatures'

    include BulkInsertSafe

    belongs_to :finding, foreign_key: 'finding_id', inverse_of: :signatures, class_name: 'Vulnerabilities::Finding'

    enum algorithm_type: { hash: 1, location: 2, scope_offset: 3 }, _prefix: :algorithm

    validates :finding, presence: true

    def self.priority(algorithm_type)
      priorities = {
        'scope_offset' => 3,
        'location' => 2,
        'hash' => 1
      }

      raise ArgumentError.new("No priority for #{algorithm_type.inspect}") unless priorities.key?(algorithm_type)

      priorities[algorithm_type]
    end

    def fingerprint_hex
      fingerprint_sha256.unpack1("H*")
    end

    def priority
      self.class.priority(algorithm_type)
    end

    def eql?(other)
      other.algorithm_type == algorithm_type &&
        other.fingerprint_sha256 == fingerprint_sha256
    end

    alias_method :==, :eql?
  end
end
