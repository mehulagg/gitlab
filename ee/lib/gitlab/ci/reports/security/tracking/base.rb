# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          class Base
            include ::Gitlab::Utils::StrongMemoize

            def self.priority
              raise NotImplementedError
            end

            def fingerprint_type
              raise NotImplementedError
            end

            def fingerprint_method
              raise NotImplementedError
            end

            def fingerprint_data
              raise NotImplementedError
            end

            # -----------------------------------------------------------------

            def ==(other)
              other.full_sha == full_sha
            end

            def inner_sha
              strong_memoize(:inner_sha) do
                Digest::SHA1.hexdigest(fingerprint_data)
              end
            end

            def full_sha
              strong_memoize(:full_sha) do
                "#{fingerprint_type}:#{fingerprint_method}:#{Digest::SHA1.hexdigest(fingerprint_data)}"
              end
            end

            def as_json(options = nil)
              full_sha # side-effect call to initialize the ivar for serialization

              super
            end

            private
          end
        end
      end
    end
  end
end
