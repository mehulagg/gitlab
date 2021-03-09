# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Secure
          class ConfigurationForm < QA::Page::Base
            include QA::Page::Component::Select2

            view 'ee/app/assets/javascripts/security_configuration/sast/components/configuration_form.vue' do
              element :submit_button
            end

            view 'ee/app/assets/javascripts/security_configuration/components/app.vue' do
              element :sast_status
            end

            view 'ee/app/assets/javascripts/security_configuration/components/expandable_section.vue' do
              element :expand_button
            end

            view 'ee/app/assets/javascripts/security_configuration/sast/components/manage_feature.vue' do
              element :sast_enable_button
            end

            def click_expand_button
              click_element :expand_button
            end

            def click_submit_button
              click_element :submit_button
            end

            def click_sast_enable_button
              click_element :sast_enable_button
            end

            def fill_dynamic_field(field_name, content)
              fill_element("#{field_name}_field", content)
            end

            def unselect_dynamic_checkbox(checkbox_name)
              uncheck_element("#{checkbox_name}_checkbox")
            end

            def has_sast_status?(status_text)
              within_element(:sast_status) do
                has_text?(status_text)
              end
            end
          end
        end
      end
    end
  end
end
