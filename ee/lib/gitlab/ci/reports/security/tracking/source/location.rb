# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          module Source
            class Location < Source::Base
              def self.priority
                ::Vulnerabilities::TrackingFingerprint.priorities[:source_location]
              end

              def track_method
                ::Vulnerabilities::TrackingFingerprint.track_methods[:location]
              end
            end
          end
        end
      end
    end
  end
end
