# frozen_string_literal: true

module QA
  module Page
    module Admin
      module Settings
        class General < Page::Base
          include QA::Page::Settings::Common

          view 'app/views/admin/application_settings/general.html.haml' do
            element :account_and_limit_settings_content
            element :signup_restrictions_content
          end

          def expand_account_and_limit(&block)
            expand_content(:account_and_limit_settings_content) do
              Component::AccountAndLimit.perform(&block)
            end
          end

          def expand_signup_restrictions(&block)
            expand_content(:signup_restrictions_content) do
              Component::Signup.perform(&block)
            end
          end
        end
      end
    end
  end
end
