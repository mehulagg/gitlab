# frozen_string_literal: true

module QA
  context 'Manage', :requires_admin, :skip_live_env do
    include Service::Shellout

    describe '2FA' do
      let!(:admin_api_client) { Runtime::API::Client.as_admin }
      let!(:owner_api_client) { Runtime::API::Client.new(:gitlab, user: owner_user) }
      let!(:developer_api_client) { Runtime::API::Client.new(:gitlab, user: developer_user) }

      let!(:owner_user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = admin_api_client
        end
      end

      let!(:developer_user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = admin_api_client
        end
      end

      let!(:ssh_key) do
        Resource::SSHKey.fabricate_via_api! do |resource|
          resource.title = "key for ssh tests #{Time.now.to_f}"
          resource.api_client = developer_api_client
        end
      end

      let!(:sandbox_group) do
        Resource::Sandbox.fabricate! do |sandbox_group|
          sandbox_group.path = "gitlab-qa-2fa-recovery-sandbox-group-#{SecureRandom.hex(4)}"
          sandbox_group.api_client = owner_api_client
        end
      end

      let!(:group) do
        QA::Resource::Group.fabricate_via_api! do |group|
          group.sandbox = sandbox_group
          group.api_client = owner_api_client
          group.require_two_factor_authentication = true
        end
      end

      let!(:project) do
        Resource::Project.fabricate! do |project|
          project.group = group
          project.name = 'ssh-recovery-test'
          project.api_client = owner_api_client
          project.initialize_with_readme = true
        end
      end

      # Might not be necessary
      let(:project_push) do
        Resource::Repository::ProjectPush.fabricate! do |push|
          push.new_branch = true
          push.branch_name = 'test-branch'
          push.project = project
          push.ssh_key = ssh_key
          push.file_name = 'text.md'
          push.file_content = '# Test Use SSH Key'
          push.commit_message = 'Add README.md'
        end
      end

      before do
        group.add_member(developer_user, Resource::Members::AccessLevel::DEVELOPER)
      end

      it 'allows using 2FA recovery code via ssh once only' do
        project_push

        enable_2fa_for_user_and_fetch_recovery_code(developer_user)

        output = Git::Repository.perform do |repository|
          repository.uri = project.repository_ssh_location.uri
          repository.use_ssh_key(ssh_key)
          repository.reset_2fa_codes
        end

        recovery_code = output.scan(/([A-Za-z0-9]{16})\n/).flatten.first

        Flow::Login.sign_in(as: developer_user, skip_page_validation: true)

        Page::Main::TwoFactorAuth.perform do |two_fa_auth|
          two_fa_auth.set_2fa_code(recovery_code)
          two_fa_auth.click_verify_code_button
        end

        expect(Page::Main::Menu.perform(&:signed_in?)).to be_truthy

        Page::Main::Menu.perform(&:sign_out)

        Flow::Login.sign_in(as: developer_user, skip_page_validation: true)

        Page::Main::TwoFactorAuth.perform do |two_fa_auth|
          two_fa_auth.set_2fa_code(recovery_code)
          two_fa_auth.click_verify_code_button
        end

        expect(page).to have_text('Invalid two-factor code')
      end

      after do
        group.set_require_two_factor_authentication(value: 'false')
        group.remove_via_api!
        sandbox_group.remove_via_api!
        developer_user.remove_via_api!
      end

      def enable_2fa_for_user_and_fetch_recovery_code(user)
        Flow::Login.while_signed_in(as: user) do
          Page::Profile::TwoFactorAuth.perform do |two_fa_auth|
            @otp = QA::Support::OTP.new(two_fa_auth.otp_secret_content)

            two_fa_auth.set_pin_code(@otp.fresh_otp)
            two_fa_auth.click_register_2fa_app_button

            recovery_code = two_fa_auth.recovery_codes.sample

            two_fa_auth.click_proceed_button

            recovery_code
          end
        end
      end
    end
  end
end
