# frozen_string_literal: true

module QA
  module Page
    module Project
      module Settings
        class ServiceDesk < QA::Page::Base
          include QA::Page::Settings::Common

          view 'app/assets/javascripts/projects/settings_service_desk/components/service_desk_setting.vue' do
            element :service_desk_template_dropdown
            element :save_service_desk_settings_button
          end

          def click_save_changes
            click_element :save_service_desk_settings_button

            wait_for_requests
          end

          def select_service_desk_email_template(template_name)
            select_element(:service_desk_template_dropdown, template_name)

            click_save_changes
          end
        end
      end
    end
  end
end
