# frozen_string_literal: true

require 'securerandom'

module QA
  # Failure issue: https://gitlab.com/gitlab-org/gitlab/issues/36107
  context 'Plan', :quarantine do
    describe 'Custom email', :requires_admin do
      before do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_admin_credentials)
        Page::Main::Menu.perform(&:click_admin_area)
        Page::Admin::Menu.perform(&:go_to_preferences_settings)
      end

      it 'customizes email with additional text' do
        random_custom_text = "Testing custom email - #{SecureRandom.hex(8)}"

        EE::Page::Admin::Settings::Preferences.perform do |preferences|
          preferences.expand_email_settings do |email_settings|
            email_settings.fill_additional_text(random_custom_text)
            email_settings.save_changes

            expect(email_settings.additional_text_textarea_text).to have_content(random_custom_text)
          end
        end
      end
    end
  end
end
