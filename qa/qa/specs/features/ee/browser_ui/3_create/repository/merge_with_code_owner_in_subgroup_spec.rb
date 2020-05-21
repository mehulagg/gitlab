# frozen_string_literal: true

module QA
  # These tests will fail unless the feature flag `skip_web_ui_code_owner_validations` is enabled.
  # That requirement is temporary. See https://gitlab.com/gitlab-org/gitlab/-/issues/217427
  # When the flag is no longer needed:
  #  - the tests will no longer need to toggle it, and
  #  - the tests will not require admin access, and
  #  - the tests can be run in live environments
  # Tracked in https://gitlab.com/gitlab-org/quality/team-tasks/-/issues/511
  context 'Create', :requires_admin, :skip_live_env do
    describe 'Codeowners' do
      before(:context) do
        @feature_flag = 'skip_web_ui_code_owner_validations'
        @feature_flag_enabled = Runtime::Feature.enabled?(@feature_flag)
        Runtime::Feature.enable_and_verify(@feature_flag) unless @feature_flag_enabled
      end

      after(:context) do
        Runtime::Feature.disable_and_verify(@feature_flag) unless @feature_flag_enabled
      end

      context 'when the project is in a subgroup' do
        let(:project) do
          Resource::Project.fabricate_via_api! do |project|
            project.name = "approve-and-merge"
            project.initialize_with_readme = true
          end
        end

        before do
          project.group.sandbox.add_member(approver, Resource::Members::AccessLevel::MAINTAINER)

          Flow::Login.sign_in

          project.visit!
        end

        after do
          project.group.sandbox.remove_member(approver)
        end

        context 'and the code owner is the root group' do
          let(:codeowner) { project.group.sandbox.path }

          it_behaves_like 'code owner merge request'
        end

        context 'and the code owner is the subgroup' do
          let(:codeowner) { project.group.full_path }

          it_behaves_like 'code owner merge request'
        end

        context 'and the code owner is a user' do
          let(:codeowner) { approver.username }

          it_behaves_like 'code owner merge request'
        end
      end
    end
  end
end
