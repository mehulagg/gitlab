# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class FindingKey
          def initialize(location_fingerprint:, identifier_fingerprint:)
            @location_fingerprint = location_fingerprint
            @identifier_fingerprint = identifier_fingerprint
          end

          def ==(other)
            location_fingerprint == other.location_fingerprint &&
              identifier_fingerprint == other.identifier_fingerprint
          end

          def hash
            location_fingerprint.hash ^ identifier_fingerprint.hash
          end

          alias_method :eql?, :==

          protected

          attr_reader :location_fingerprint, :identifier_fingerprint
        end
      end
    end
  end
end
