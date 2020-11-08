# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Locations
          class Base
            include ::Gitlab::Utils::StrongMemoize

            def ==(other)
              other.fingerprint == fingerprint
            end

            def fingerprint_type
              ""
            end

            def fingerprint_method
              ""
            end

            def fingerprint
              strong_memoize(:fingerprint) do
                "#{fingerprint_type}:#{Digest::SHA1.hexdigest(fingerprint_data)}"
              end
            end

            def as_json(options = nil)
              fingerprint # side-effect call to initialize the ivar for serialization

              super
            end

            private

            def fingerprint_data
              raise NotImplemented
            end
          end
        end
      end
    end
  end
end
