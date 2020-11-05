# frozen_string_literal: true

module QA
  module Page
    module Admin
      module Settings
        module Component
          class Signup < QA::Page::Base
            view 'app/views/admin/application_settings/_signup.html.haml' do
              element :save_changes_button
              element :signup_enabled_checkbox
            end

            def disable_signups
              uncheck_element :signup_enabled_checkbox
            end

            def save_changes
              click_element(:save_changes_button)
            end
          end
        end
      end
    end
  end
end

