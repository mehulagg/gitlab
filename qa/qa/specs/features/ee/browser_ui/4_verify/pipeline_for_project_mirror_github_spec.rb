# frozen_string_literal: true

require 'github_api'
require 'faker'
require 'base64'

module QA
  context 'Verify', :github, :requires_admin, only: { subdomain: :staging }, quarantine: { issue: 'https://gitlab.com/gitlab-org/gitlab/-/issues/335045', type: :bug } do
    include Support::Api

    describe 'Pipeline for project mirrors Github' do
      let(:commit_message) { "Update #{github_data[:file_name]} - #{Time.now}" }
      let(:project_name) { 'github-project-with-pipeline' }
      let(:github_client) { Github::Client::Repos::Contents.new oauth_token: github_data[:access_token] }
      let(:admin_api_client) { Runtime::API::Client.as_admin }
      let(:user_api_client) { Runtime::API::Client.new(:gitlab, user: user) }

      let(:group) do
        Resource::Group.fabricate_via_api!
      end

      let(:user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = admin_api_client
          resource.hard_delete_on_api_removal = true
        end
      end

      let(:import_project) do
        EE::Resource::ImportRepoWithCICD.fabricate_via_browser_ui! do |project|
          project.import = true
          project.name = project_name
          project.github_personal_access_token = github_data[:access_token]
          project.github_repository_path = github_data[:repo_name]
        end
      end

      before do
        # Create both tokens before logging in the first time so that we don't need to log out in the middle of the test
        admin_api_client.personal_access_token
        user_api_client.personal_access_token

        group.add_member(user, Resource::Members::AccessLevel::OWNER)
        Flow::Login.sign_in(as: user)
        group.visit!
        import_project
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
      end

      after do
        remove_project
        group.remove_via_api!
        user.remove_via_api!
      end

      it 'user commits to GitHub triggers CI pipeline', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/144' do
        Page::Project::Pipeline::Index.perform do |index|
          expect(index).to have_no_pipeline, 'Expect to have NO pipeline before mirroring.'

          edit_github_file
          trigger_project_mirror
          index.wait_until(reload: false) { index.has_pipeline? }

          expect(index).to have_content(commit_message), 'Expect new pipeline to have latest commit message from Github.'
        end
      end

      private

      def github_data
        {
            access_token: Runtime::Env.github_access_token,
            repo_owner: 'gitlab-qa-github',
            repo_name: 'test-project',
            file_name: 'text_file.txt'
        }
      end

      def edit_github_file
        Runtime::Logger.info "Making changes to Github file."

        file = github_client.get github_data[:repo_owner], github_data[:repo_name], github_data[:file_name]
        file_sha = file.body['sha']
        file_path = file.body['path']
        file_new_content = Faker::Lorem.sentence

        github_client.update(github_data[:repo_owner], github_data[:repo_name], github_data[:file_name],
                             path: file_path, message: commit_message,
                             content: file_new_content,
                             sha: file_sha)

        Support::Retrier.retry_until(max_attempts: 5, sleep_interval: 2) do
          Base64.decode64(github_client.get(user: github_data[:repo_owner], repo: github_data[:repo_name], path: file_path)&.content) == file_new_content
        end
      end

      def import_project_id
        request = Runtime::API::Request.new(user_api_client, import_project.api_get_path)
        JSON.parse(get(request.url))['id']
      end

      def trigger_project_mirror
        Runtime::Logger.info "Triggering pull mirror request."

        request = Runtime::API::Request.new(user_api_client, "/projects/#{import_project_id}/mirror/pull")
        Support::Retrier.retry_until(max_attempts: 6, sleep_interval: 10) do
          response = post(request.url, nil)
          Runtime::Logger.info "Mirror pull request response: #{response}"
          response.code == Support::Api::HTTP_STATUS_OK
        end
      end

      def remove_project
        delete_project_request = Runtime::API::Request.new(user_api_client, "/projects/#{CGI.escape("#{Runtime::Namespace.path}/#{import_project.name}")}")
        delete delete_project_request.url
      end
    end
  end
end
