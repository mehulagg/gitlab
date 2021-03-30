# frozen_string_literal: true

module QA
  RSpec.describe 'Manage', :group_saml, :orchestrated, :requires_admin, quarantine: { issue: 'https://gitlab.com/gitlab-org/gitlab/issues/202260', type: :bug } do
    describe 'Group SAML SSO - Enforced SSO' do
      include Support::Api

      before(:all) do
        # Create a new user (with no existing SAML identities) who will be added as owner to the SAML group.
        @owner_user = Resource::User.fabricate_via_api!

        Flow::Login.sign_in(as: @owner_user)

        @group = Resource::Sandbox.fabricate_via_api! do |sandbox_group|
          sandbox_group.path = "saml_sso_group_#{SecureRandom.hex(8)}"
        end

        [:group_scim, :group_administration_nav_item, :invite_members_group_modal].each do |flag|
          Runtime::Feature.enable(flag)
        end

        @saml_idp_service = Flow::Saml.run_saml_idp_service(@group.path)

        @api_client = Runtime::API::Client.as_admin

        @group.add_member(@owner_user, QA::Resource::Members::AccessLevel::OWNER)

        @managed_group_url = Flow::Saml.enable_saml_sso(@group, @saml_idp_service)

        @saml_linked_for_admin = false

        enable_enforce_sso

        Page::Main::Menu.perform(&:sign_out_if_signed_in)

        Flow::Saml.logout_from_idp(@saml_idp_service)
      end

      it 'creates a new account automatically and allows to leave group and join again', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/708' do
        visit_managed_group_url

        EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

        Flow::Saml.login_to_idp_if_required('user3', 'user3pass')

        expect(page).to have_text("You have to confirm your email address before continuing")

        QA::Flow::User.confirm_user('user_3@example.com')

        visit_managed_group_url

        EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

        expect(page).to have_text("Signed in with SAML")

        Page::Group::Show.perform(&:leave_group)

        expect(page).to have_text("You left")

        Page::Main::Menu.perform(&:sign_out)

        Flow::Saml.logout_from_idp(@saml_idp_service)

        # When a user exists with a linked identity

        visit_managed_group_url

        EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

        Flow::Saml.login_to_idp_if_required('user3', 'user3pass')

        expect(page).to have_text("Login to a GitLab account to link with your SAML identity")

        Flow::Saml.logout_from_idp(@saml_idp_service)

        # When no user exists with a linked identity

        remove_user_if_exists('user_3@example.com')

        visit_managed_group_url

        EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

        Flow::Saml.login_to_idp_if_required('user3', 'user3pass')

        expect(page).to have_text("You have to confirm your email address before continuing")
      end

      after(:all) do
        page.visit Runtime::Scenario.gitlab_address

        [:group_scim, :group_administration_nav_item].each do |flag|
          Runtime::Feature.remove(flag)
        end

        remove_user_if_exists('user_3@example.com')

        @group.remove_via_api!

        Flow::Saml.remove_saml_idp_service(@saml_idp_service)

        page.visit Runtime::Scenario.gitlab_address
        Page::Main::Menu.perform(&:sign_out_if_signed_in)
      end
    end

    def remove_user_if_exists(username_or_email)
      QA::Runtime::Logger.debug("Attempting to remove user \"#{username_or_email}\" via API")

      return if username_or_email.nil?

      response = parse_body(get(Runtime::API::Request.new(@api_client, "/users?search=#{username_or_email}").url))

      if response.any?
        raise "GET /users?search=#{username_or_email} returned multiple results. response: #{response}" if response.size > 1

        delete_response = delete Runtime::API::Request.new(@api_client, "/users/#{response.first[:id]}").url

        QA::Runtime::Logger.debug("DELETE \"#{username_or_email}\" response code: #{delete_response.code} message: #{delete_response.body}")
      else
        QA::Runtime::Logger.debug("GET /users?search=#{username_or_email} returned empty response: #{response}")
      end
    end

    def enable_enforce_sso
      Support::Retrier.retry_on_exception do
        # We need to logout from IDP. This is required if this is a retry.
        Flow::Saml.logout_from_idp(@saml_idp_service)

        page.visit Runtime::Scenario.gitlab_address

        Page::Main::Menu.perform(&:sign_out_if_signed_in)

        # The first time you have to be signed in as admin
        unless @saml_linked_for_admin
          Flow::Login.sign_in(as: @owner_user)
          @saml_linked_for_admin = true
        end

        # Sign in with SAML before enabling enforce sso
        visit_managed_group_url

        EE::Page::Group::SamlSSOSignIn.perform(&:click_sign_in)

        Flow::Saml.login_to_idp_if_required('user1', 'user1pass')

        Flow::Saml.visit_saml_sso_settings(@group)

        EE::Page::Group::Settings::SamlSSO.perform do |saml_sso|
          # Once the feature flags are enabled, it takes some time for the toggle buttons to show on the UI.
          # This issue does not happen manually. Only happens with the test as they are too fast.
          Support::Retrier.retry_until(sleep_interval: 1, raise_on_failure: true) do
            condition_met = saml_sso.has_enforced_sso_button?
            page.refresh unless condition_met

            condition_met
          end

          saml_sso.enforce_sso
          saml_sso.click_save_changes

          saml_sso.user_login_url_link_text
        end
      end
    end

    def visit_managed_group_url
      Runtime::Logger.debug(%Q[Visiting managed_group_url at "#{@managed_group_url}"])

      page.visit @managed_group_url
      Support::Waiter.wait_until { current_url == @managed_group_url }
    end
  end
end
