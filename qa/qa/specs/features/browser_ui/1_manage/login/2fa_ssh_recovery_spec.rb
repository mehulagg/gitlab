# frozen_string_literal: true

module QA
  context 'Manage', :requires_admin, :skip_live_env do
    describe '2FA' do
      let!(:user) { Resource::User.fabricate_via_api! }

      let!(:user_api_client) { Runtime::API::Client.new(:gitlab, user: user) }

      let!(:ssh_key) do
        Resource::SSHKey.fabricate_via_api! do |resource|
          resource.title = "key for ssh tests #{Time.now.to_f}"
          resource.api_client = user_api_client
        end
      end

      before do
        enable_2fa_for_user(user)
      end

      it 'allows 2FA code recovery via ssh' do
        output = Git::Repository.perform do |repository|
          host = URI.parse(QA::Runtime::Scenario.gitlab_address).host
          port = URI.parse(QA::Runtime::Scenario.gitlab_address).port

          port = port == '22' ? '' : '2222'

          repository.uri = URI::HTTP.build(host: host, port: port)

          repository.use_ssh_key(ssh_key)

          repository.reset_2fa_codes
        end

        recovery_code = output.scan(/([A-Za-z0-9]{16})\n/).flatten.first

        Flow::Login.sign_in(as: user, skip_page_validation: true)

        Page::Main::TwoFactorAuth.perform do |two_fa_auth|
          two_fa_auth.set_2fa_code(recovery_code)
          two_fa_auth.click_verify_code_button
        end

        expect(Page::Main::Menu.perform(&:signed_in?)).to be_truthy
      end

      def enable_2fa_for_user(user)
        Flow::Login.while_signed_in(as: user) do
          Page::Main::Menu.perform(&:click_settings_link)
          Page::Profile::Menu.perform(&:click_account)
          Page::Profile::Accounts::Show.perform(&:click_enable_2fa_button)

          Page::Profile::TwoFactorAuth.perform do |two_fa_auth|
            @otp = QA::Support::OTP.new(two_fa_auth.otp_secret_content)

            two_fa_auth.set_pin_code(@otp.fresh_otp)
            two_fa_auth.click_register_2fa_app_button
            two_fa_auth.click_proceed_button
          end
        end
      end
    end
  end
end
