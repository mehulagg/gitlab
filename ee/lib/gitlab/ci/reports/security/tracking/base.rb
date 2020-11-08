# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          class Base < ::Gitlab::Ci::Reports::Security::Locations::Base
            include ::Gitlab::Utils::StrongMemoize

            def ==(other)
              other.fingerprint == fingerprint &&
                other.fingerprint_type == fingerprint_type &&
                other.fingerprint_method == fingerprint_method
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

            def fingerprint
              strong_memoize(:fingerprint) do
                "#{fingerprint_type}:#{fingerprint_method}:#{Digest::SHA1.hexdigest(fingerprint_data)}"
              end
            end

            def as_json(options = nil)
              fingerprint # side-effect call to initialize the ivar for serialization

              super
            end

            private
          end
        end
      end
    end
  end
end
