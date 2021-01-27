# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify', :runner do
    include Support::Api

    describe 'Pipeline with protected variable' do
      let(:executor) { "qa-runner-#{Faker::Alphanumeric.alphanumeric(8)}" }
      let(:protected_value) { Faker::Alphanumeric.alphanumeric(8) }
      let!(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-ci-variables'
          project.description = 'project with CI variables'
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.project = project
          runner.name = executor
          runner.tags = [executor]
        end
      end

      let!(:ci_file) do
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files(
              [
                  {
                      file_path: '.gitlab-ci.yml',
                      content: <<~YAML
                        job:
                          tags:
                            - #{executor}
                          script: echo $PROTECTED_VARIABLE
                      YAML
                  }
              ]
          )
        end
      end

      let(:developer) do
        Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1)
      end

      let(:guest) do
        Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_2, Runtime::Env.gitlab_qa_password_2)
      end

      let(:dev_api_client) { Runtime::API::Client.new(:gitlab, user: developer) }
      let(:guest_api_client) { Runtime::API::Client.new(:gitlab, user: guest) }

      let(:root_api) { Runtime::API::Client.new(:gitlab) }

      before do
        Flow::Login.sign_in
        project.visit!
        add_ci_variable
        project.add_member(developer, Resource::Members::AccessLevel::DEVELOPER)
        project.add_member(guest, Resource::Members::AccessLevel::GUEST)
      end

      after do
        runner.remove_via_api!
      end

      it 'executes variable on protected branch', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/156' do
        Flow::Login.sign_in(as: developer)
        Resource::Pipeline.fabricate_via_api! do |pipeline|
          pipeline.project = project
        end
        project.visit!

        Flow::Pipeline.visit_latest_pipeline(pipeline_condition: 'completed')
        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('job')
        end
      end

      it 'does not execute variable on unprotected branch', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/156' do
        Flow::Login.sign_in(as: guest)
        Resource::Pipeline.fabricate_via_api! do |pipeline|
          pipeline.project = project
        end
        project.visit!

        Flow::Pipeline.visit_latest_pipeline(pipeline_condition: 'completed')
        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('job')
        end
      end

      private

      def add_ci_variable
        Resource::CiVariable.fabricate_via_browser_ui! do |ci_variable|
          ci_variable.project = project
          ci_variable.key = 'PROTECTED_VARIABLE'
          ci_variable.value = protected_value
          ci_variable.masked = false
        end
      end

      def create_protected_branch
        Resource::ProtectedBranch.fabricate_via_api! do |resource|
          resource.branch_name = branch_name
          resource.project = project
          resource.allowed_to_push = allowed_to_push
        end
      end

      def push_new_file(branch_name)
        Resource::Repository::ProjectPush.fabricate! do |resource|
          resource.project = project
          resource.file_name = 'new_file.md'
          resource.file_content = '# This is a new file'
          resource.commit_message = 'Add new_file.md'
          resource.branch_name = branch_name
          resource.new_branch = false
          resource.wait_for_push = false
        end
      end
    end
  end
end
