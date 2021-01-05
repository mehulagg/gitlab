# frozen_string_literal: true

require 'github_api'
require 'faker'

module QA
  context 'Verify', :github, only: { subdomain: :staging } do
    include Support::Api

    describe 'Pipeline for project mirrors Github' do
      let(:commit_message) { "Update #{github_data[:file_name]} - #{Time.now}" }
      let(:project_name) { 'github-project-with-pipeline' }
      let(:api_client) { Runtime::API::Client.new(:gitlab) }

      let(:import_project) do
        EE::Resource::ImportRepoWithCICD.fabricate_via_browser_ui! do |project|
          project.import = true
          project.name = project_name
          project.github_personal_access_token = github_data[:access_token]
          project.github_repository_path = github_data[:repo_name]
        end
      end

      before do
        Flow::Login.sign_in
        import_project
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
      end

      after do
        remove_project
      end

      it 'user commits to GitHub triggers CI pipeline', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/144' do
        Page::Project::Pipeline::Index.perform do |index|
          expect(index).to have_no_pipeline

          edit_github_file
          trigger_project_mirror
          index.refresh

          aggregate_failures 'new pipeline for new github commit' do
            expect(index).to have_pipeline
            expect(index).to have_content(commit_message)
          end
        end
      end

      private

      def visit_project
        Page::Main::Menu.perform(&:go_to_projects)
        Page::Dashboard::Projects.perform do |dashboard|
          dashboard.go_to_project(project_name)
        end
      end

      def github_data
        {
            access_token: Runtime::Env.github_access_token,
            repo_owner: 'gitlab-qa-github',
            repo_name: 'test-project',
            file_name: 'text_file.txt'
        }
      end

      def github_client
        Github::Client::Repos::Contents.new oauth_token: github_data[:access_token]
      end

      def edit_github_file
        file = github_client.get github_data[:repo_owner], github_data[:repo_name], github_data[:file_name]
        file_sha = file.body['sha']
        file_path = file.body['path']
        github_client.update(github_data[:repo_owner], github_data[:repo_name], github_data[:file_name],
                             path: file_path, message: commit_message,
                             content: Faker::Lorem.sentence,
                             sha: file_sha)

        sleep 5 # allow some time for github to update itself
      end

      def import_project_id
        request = Runtime::API::Request.new(api_client, import_project.api_get_path)
        JSON.parse(get request.url)['id']
      end

      def trigger_project_mirror
        request = Runtime::API::Request.new(api_client, "/projects/#{import_project_id}/mirror/pull")
        post(request.url, nil)

        sleep 5 # allow some time for mirroring to finish, post request response only returns 200
      end

      def remove_project
        delete_project_request = Runtime::API::Request.new(api_client, "/projects/#{CGI.escape("#{Runtime::Namespace.path}/#{import_project.name}")}")
        delete delete_project_request.url
      end
    end
  end
end
