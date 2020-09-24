# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        class SamlSSOSignUp < QA::Page::Base
          view 'ee/app/views/groups/sso/_register_pane.html.haml' do
            element :sign_out_and_register_button
            element :new_user_email_field
            element :new_user_username_field
            element :new_user_register_button
          end

          def click_register_button
            click_element :new_user_register_button
          end

          def click_signout_and_register_button
            click_element :sign_out_and_register_button
          end

          def current_email
            find_element(:new_user_email_field)[:value]
          end

          def current_username
            find_element(:new_user_username_field)[:value]
          end
        end
      end
    end
  end
end
