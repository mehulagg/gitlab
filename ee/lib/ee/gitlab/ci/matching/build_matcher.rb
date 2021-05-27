# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Matching
        module BuildMatcher
          def not_matched_failure_reason
            if project.shared_runners_enabled_but_unavailable?
              :ci_quota_exceeded
            else
              super
            end
          end
        end
      end
    end
  end
end
