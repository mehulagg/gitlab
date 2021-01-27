# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          module Source
            class ScopeOffset < Source::Base
              def self.priority
                ::Vulnerabilities::TrackingFingerprint.priorities[:source_scope_offset]
              end

              def track_method
                ::Vulnerabilities::TrackingFingerprint.track_methods[:scope_offset]
              end
            end
          end
        end
      end
    end
  end
end
