# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        module Settings
          class SamlSSO < ::QA::Page::Base
            view 'ee/app/views/groups/saml_providers/_form.html.haml' do
              element :identity_provider_sso_field
              element :certificate_fingerprint_field
              element :enforced_sso_toggle_button
              element :group_managed_accounts_toggle_button
              element :save_changes_button
            end

            view 'ee/app/views/groups/saml_providers/_test_button.html.haml' do
              element :saml_settings_test_button
            end

            view 'ee/app/views/groups/saml_providers/_info.html.haml' do
              element :user_login_url_link
            end

            def set_id_provider_sso_url(url)
              fill_element :identity_provider_sso_field, url
            end

            def set_cert_fingerprint(fingerprint)
              fill_element :certificate_fingerprint_field, fingerprint
            end

            def has_enforced_sso_button?
              has_element?(:enforced_sso_toggle_button, wait: 1.0)
            end

            def enforce_sso_enabled?
              find_element(:enforced_sso_toggle_button)[:class].include?('is-checked')
            end

            def enforce_sso
              Support::Retrier.retry_until(sleep_interval: 1.0, raise_on_failure: true) do
                click_element :enforced_sso_toggle_button unless enforce_sso_enabled?
                enforce_sso_enabled?
              end
            end

            def disable_enforced_sso
              Support::Retrier.retry_until(sleep_interval: 1.0, raise_on_failure: true) do
                click_element :enforced_sso_toggle_button if enforce_sso_enabled?
                !enforce_sso_enabled?
              end
            end

            def has_group_managed_accounts_button?
              has_element?(:group_managed_accounts_toggle_button, wait: 1.0)
            end

            def group_managed_accounts_enabled?
              find_element(:group_managed_accounts_toggle_button)[:class].include?('is-checked')
            end

            def enable_group_managed_accounts
              Support::Retrier.retry_until(sleep_interval: 1.0, raise_on_failure: true) do
                click_element :group_managed_accounts_toggle_button unless group_managed_accounts_enabled?
                group_managed_accounts_enabled?
              end
            end

            def disable_group_managed_accounts
              Support::Retrier.retry_until(sleep_interval: 1.0, raise_on_failure: true) do
                click_element :group_managed_accounts_toggle_button if group_managed_accounts_enabled?
                !group_managed_accounts_enabled?
              end
            end

            def click_save_changes
              click_element :save_changes_button
            end

            def click_test_button
              click_element :saml_settings_test_button
            end

            def click_user_login_url_link
              click_element :user_login_url_link
            end

            def user_login_url_link_text
              find_element(:user_login_url_link).text
            end
          end
        end
      end
    end
  end
end
