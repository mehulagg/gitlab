# frozen_string_literal: true
require 'securerandom'

module QA
  # Failure issue: https://gitlab.com/gitlab-org/gitlab/issues/36107
  context 'Manage', :quarantine do
    shared_examples 'instance audit event logs' do |expected_events|
      it 'logs audit events for UI operations' do
        sign_in

        Page::Main::Menu.perform(&:click_admin_area)
        QA::Page::Admin::Menu.perform(&:go_to_monitoring_audit_logs)
        EE::Page::Admin::Monitoring::AuditLog.perform do |audit_log_page|
          expected_events.each do |expected_event|
            expect(audit_log_page).to have_audit_log_row(expected_event)
          end
        end
      end
    end

    describe 'Instance audit logs', :requires_admin do
      context 'Failed sign in' do
        before do
          Runtime::Browser.visit(:gitlab, Page::Main::Login)
          invalid_user = QA::Resource::User.new.tap do |user|
            user.username = 'bad_user_name'
            user.password = 'bad_pasword'
          end

          Page::Main::Login.perform do |login_page|
            login_page.sign_in_using_credentials(user: invalid_user, skip_page_validation: true)
          end
          sign_in
        end

        it_behaves_like 'instance audit event logs', ["Failed to login with STANDARD authentication"]
      end

      context 'Successful sign in' do
        before do
          sign_in
        end

        it_behaves_like 'instance audit event logs', ["Signed in with STANDARD authentication"]
      end

      context 'Add SSH key' do
        before do
          sign_in
          Resource::SSHKey.fabricate! do |resource|
            resource.title = "key for instance audit event logs test #{Time.now.to_f}"
          end
        end

        it_behaves_like 'instance audit event logs', ["Added SSH key"]
      end

      context 'Add and delete email' do
        before do
          sign_in
          new_email_address = 'new_email@example.com'
          Page::Main::Menu.perform(&:click_settings_link)
          Page::Profile::Menu.perform(&:click_emails)
          Page::Profile::Emails.perform do |emails|
            emails.add_email_address(new_email_address)
            emails.delete_email_address(new_email_address)
          end
        end

        it_behaves_like 'instance audit event logs', ["Added email", "Removed email"]
      end

      context 'Change password', :skip_signup_disabled do
        before do
          user = Resource::User.fabricate_via_api! do |user|
            user.username = "user_#{SecureRandom.hex(4)}"
            user.password = "pw_#{SecureRandom.hex(4)}"
          end
          Runtime::Browser.visit(:gitlab, Page::Main::Login)

          Page::Main::Login.perform do |login_page|
            login_page.sign_in_using_credentials(user: user)
          end

          Page::Main::Menu.perform(&:click_settings_link)
          Page::Profile::Menu.perform(&:click_password)
          Page::Profile::Password.perform do |password_page|
            password_page.update_password('new_password', user.password)
          end
          sign_in
        end

        it_behaves_like 'instance audit event logs', ["Changed password"]
      end

      context 'Start and stop user impersonation' do
        before do
          sign_in
          user = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1)
          Page::Main::Menu.perform(&:click_admin_area)
          Page::Admin::Menu.perform(&:go_to_users_overview)
          Page::Admin::Overview::Users::Index.perform do |index|
            index.search_user(user.username)
            index.click_user(user.username)
          end

          Page::Admin::Overview::Users::Show.perform(&:click_impersonate_user)

          Page::Main::Menu.perform(&:click_stop_impersonation_link)
        end

        it_behaves_like 'instance audit event logs', ["Started Impersonation", "Stopped Impersonation"]
      end

      def sign_in
        Page::Main::Menu.perform(&:sign_out_if_signed_in)
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_admin_credentials)
      end
    end
  end
end
