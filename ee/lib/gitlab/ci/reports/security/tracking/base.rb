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

            def priority
              self.class.priority
            end
            alias_method :priority_raw, :priority

            def track_type
              raise NotImplementedError
            end

            def track_method
              raise NotImplementedError
            end

            def track_data
              raise NotImplementedError
            end

            def location_hash
              raise NotImplementedError
            end

            # -----------------------------------------------------------------

            def ==(other)
              other.sha == sha
            end

            def type_key
              # these are integer values, not strings
              "#{track_type}:#{track_method}"
            end

            def sha
              strong_memoize(:sha) do
                Digest::SHA1.hexdigest(track_data)
              end
            end
            alias_method :fingerprint, :sha

            def same_type?(other)
              other.track_type == track_type &&
                other.track_method == track_method
            end

            def as_json(options = nil)
              sha # side-effect call to initialize the ivar for serialization

              super
            end

            def to_create_hash
              %i[
                track_type
                track_method
                priority
                sha
              ].each_with_object({}) do |key, hash|
                hash[key] = public_send(key) # rubocop:disable GitlabSecurity/PublicSend
              end
            end

            # for compatibility with the Location objects, the normal to_hash
            # method needs to return the same type of information as a
            # location hash
            def to_hash
              location_hash
            end
          end
        end
      end
    end
  end
end
