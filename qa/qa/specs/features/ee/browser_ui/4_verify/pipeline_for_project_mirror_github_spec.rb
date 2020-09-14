# frozen_string_literal: true

require 'github_api'
require 'faker'

module QA
  context 'Verify', :github, :docker, :skip_live_env do
    include Support::Api

    describe 'Pipeline for project mirrors Github' do
      let(:commit_message) { "Update #{github_data[:file_name]} - #{Time.now}" }
      let(:project_name) { 'github-project-with-pipeline' }
      let(:executor) { "qa-runner-#{Time.now.to_i}" }
      let(:api_client) { Runtime::API::Client.new(:gitlab) }

      let(:imported_project) do
        EE::Resource::ImportRepoWithCICD.fabricate_via_browser_ui! do |project|
          project.import = true
          project.name = project_name
          project.github_personal_access_token = github_data[:access_token]
          project.github_repository_path = github_data[:repo_name]
        end
      end

      let(:runner) do
        Resource::Runner.fabricate_via_api! do |runner|
          runner.project = imported_project
          runner.name = executor
          runner.token = imported_project.group.sandbox.runners_token
          runner.tags = [executor]
        end
      end

      before do
        Flow::Login.sign_in
        runner
        imported_project.visit!
        trigger_project_mirror

        edit_github_file

        imported_project.visit!
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
      end

      after do
        remove_runner
        remove_project
      end

      it 'user commits to GitHub triggers CI pipeline' do
        Page::Project::Pipeline::Index.perform do |this_page|
          expect(this_page).to have_pipeline

          this_page.wait_for_latest_pipeline_completion
          expect(this_page).to have_content(commit_message)
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
            uri: 'https://github.com/gitlab-qa-github/test-project.git',
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
        github_client.update github_data[:repo_owner], github_data[:repo_name], github_data[:file_name],
                             path: file_path, message: commit_message,
                             content: Faker::Lorem.sentence,
                             sha: file_sha
      end

      def trigger_project_mirror
        Page::Project::Menu.perform(&:go_to_repository_settings)
        Page::Project::Settings::Repository.perform do |settings|
          settings.expand_mirroring_repositories do |mirror_settings|
            mirror_settings.update
          end
        end
      end

      def remove_runner
        delete_runners_request = Runtime::API::Request.new(api_client, "/runners/#{runner_id}")
        delete delete_runners_request.url

        Service::DockerRun::GitlabRunner.new(runner.name).remove!
      end

      def runner_id
        get_runners_request = Runtime::API::Request.new(api_client, "/runners")
        runners = JSON.parse(get(get_runners_request.url))
        this_runner = runners.detect { |runner| runner['description'] == project_name }

        this_runner['id']
      end

      def remove_project
        delete_project_request = Runtime::API::Request.new(api_client, "/projects/#{CGI.escape("#{Runtime::Namespace.path}/#{project_name}")}")
        delete delete_project_request.url
      end
    end
  end
end
