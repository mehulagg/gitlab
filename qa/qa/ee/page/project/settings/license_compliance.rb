# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Settings
          class LicenseCompliance < QA::Page::Base
            include QA::Page::Component::Select2 # Select2 is an external library, so we can't add our own selectors

            view 'ee/app/assets/javascripts/vue_shared/license_compliance/license_management.vue' do
              element :license_add_button
            end

            view 'ee/app/assets/javascripts/vue_shared/license_compliance/components/add_license_form.vue' do
              element :license_radio, 'data-qa-selector="`${option.value}_license_radio`"' # rubocop:disable QA/ElementWithPattern
              element :add_license_submit_button
            end

            view 'ee/app/assets/javascripts/vue_shared/license_compliance/license_management.vue' do
              element :license_compliance_list
            end

            view 'ee/app/assets/javascripts/vue_shared/license_compliance/components/admin_license_management_row.vue' do
              element :admin_license_compliance_row
              element :license_name_content
            end

            view 'app/assets/javascripts/reports/components/issue_status_icon.vue' do
              element :icon_status, ':data-qa-selector="`status_${status}_icon`" ' # rubocop:disable QA/ElementWithPattern
            end

            def has_approved_license?(name)
              within_element(:admin_license_compliance_row, text: name) do
                has_element?(:status_success_icon)
              end
            end

            def has_denied_license?(name)
              within_element(:admin_license_compliance_row, text: name) do
                has_element?(:status_failed_icon)
              end
            end

            def approve_license(license)
              click_element :license_add_button
              expand_select_list
              search_and_select license
              click_element :approved_license_radio
              click_element :add_license_submit_button

              has_approved_license? license
            end

            def deny_license(license)
              click_element :license_add_button
              expand_select_list
              search_and_select license
              click_element :blacklisted_license_radio
              click_element :add_license_submit_button

              has_denied_license? license
            end
          end
        end
      end
    end
  end
end
