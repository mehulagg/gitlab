# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module Summary
        class LeadTime < BaseTime
          def title
            _('Lead Time')
          end

          def start_event_identifier
            :issue_created
          end

          def end_event_identifier
            :issue_closed
          end
        end
      end
    end
  end
end
