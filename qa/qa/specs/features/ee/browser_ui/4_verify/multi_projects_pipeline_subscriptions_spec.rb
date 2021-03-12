# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify' do
    describe 'Multi projects pipeline subscription', :runner do
      let(:executor) { "qa-runner-#{Faker::Alphanumeric.alphanumeric(8)}" }
      let(:branch_name) { "awesome-tag-#{Faker::Alphanumeric.alphanumeric(12)}" }
      let(:user) do
        Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1)
      end

      let(:user_api_client) { Runtime::API::Client.new(:gitlab, user: user) }

      let!(:downstream_project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'downstream-project-for-subscription'
          project.description = 'Project with CI subscription'
        end
      end

      let!(:ci_file) do
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = downstream_project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files(
              [
                {
                  file_path: '.gitlab-ci.yml',
                  content: <<~YAML
                    job:
                      tags:
                        - #{executor}
                      script: echo DONE!
                  YAML
                }
              ]
          )
        end
      end

      let(:upstream_project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'upstream-project-for-subscription'
          project.description = 'Project with CI subscription'
        end
      end

      let(:user_project) do
        Resource::Fork.fabricate_via_api! do |fork|
          fork.user = user
          fork.upstream = downstream_project
          fork.name = "user_project-#{Faker::Alphanumeric.alphanumeric(12)}"
        end.project
      end

      before do
        create_new_tag(user_project)

        Flow::Login.sign_in
        downstream_project.visit!

        puts "****** WATCH SUBSCRIBING *******"

        sleep 3
        EE::Resource::PipelineSubscriptions.fabricate_via_browser_ui! do |resource|
          resource.project_path = user_project.api_get_path
        end

        sleep 10
      end

      it 'test something there' do

      end

      private

      def create_new_tag(project)
        Resource::Tag.fabricate_via_api! do |tag|
          tag.project = project
          tag.ref = project.default_branch
          tag.name = branch_name
        end
      end
    end
  end
end
