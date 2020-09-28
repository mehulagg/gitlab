# frozen_string_literal: true

module QA
  module EE
    module Page
      module Component
        module LicenseManagement
          extend QA::Page::PageConcern

          def self.prepended(base)
            super

            base.class_eval do
              view 'app/assets/javascripts/reports/components/report_item.vue' do
                element :report_item_row
              end

              view 'app/assets/javascripts/reports/components/issue_status_icon.vue' do
                element :icon_status, ':data-qa-selector="`status_${status}_icon`" ' # rubocop:disable QA/ElementWithPattern
              end

              view 'ee/app/assets/javascripts/vue_shared/license_compliance/components/set_approval_status_modal.vue' do
                element :license_management_modal
              end

              view 'ee/app/assets/javascripts/vue_shared/license_compliance/mr_widget_license_report.vue' do
                element :license_report_widget
              end
            end
          end

          def click_license(name)
            within_element(:license_report_widget) do
              click_on name
            end
            wait_for_animated_element(:license_management_modal)
          end
        end
      end
    end
  end
end
