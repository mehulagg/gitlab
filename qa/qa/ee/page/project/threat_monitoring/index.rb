# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module ThreatMonitoring
          class Index < QA::Page::Base
            TAB_INDEX = {
              alerts: 1,
              policies: 2,
              statistics: 3 # it hasn't been added yet
            }.freeze

            view 'ee/app/assets/javascripts/threat_monitoring/components/app.vue' do
              element :alerts_tab
              element :policies_tab
              element :threat_monitoring_container
            end

            def has_alerts_tab?
              has_element?(:alerts_tab)
            end

            def has_policies_tab?
              has_element?(:policies_tab)
            end

            def click_policies_tab
              within_element(:threat_monitoring_container) do
                find(tab_element_for(:policies)).click
              end
            end

            private

            def tab_element_for(tab_name)
              "a[aria-posinset='#{TAB_INDEX[tab_name]}']"
            end
          end
        end
      end
    end
  end
end
