# frozen_string_literal: true

module QA
  module Page
    module ThreatMonitoring
      class AlertsList < Page::Base
        view 'ee/app/assets/javascripts/threat_monitoring/components/app.vue' do
          element :alerts_tab
        end

        view 'ee/app/assets/javascripts/threat_monitoring/components/alerts/alerts_list.vue' do
          element :alerts_list
        end

        def has_alerts_tab?
          find_element?(:alerts_tab)
        end

        def has_alerts_list?
          find_element?(:alerts_list)
        end
      end
    end
  end
end
