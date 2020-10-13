# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        module Settings
          class Preferences < QA::Page::Base
            include QA::Page::Settings::Common

            view 'app/views/admin/application_settings/preferences.html.haml' do
              element :email_content
            end

            def expand_email_settings(&block)
              expand_content(:email_content) do
                Component::Email.perform(&block)
              end
            end
          end
        end
      end
    end
  end
end
