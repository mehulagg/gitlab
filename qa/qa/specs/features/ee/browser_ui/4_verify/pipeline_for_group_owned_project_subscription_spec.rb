# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify' do
    describe 'Multi projects pipeline subscription', :runner do
      let(:executor) { "qa-runner-#{Faker::Alphanumeric.alphanumeric(8)}" }
      let(:tag_name) { "awesome-tag-#{Faker::Alphanumeric.alphanumeric(12)}" }

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-pipeline-subscription'
          project.description = 'Project with CI subscription'
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.project = project
          runner.name = executor
          runner.tags = [executor]
        end
      end

      let!(:upstream_project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'upstream-project-for-subscription'
          project.description = 'Project with CI subscription'
        end
      end

      before do
        [project, upstream_project].each do |target|
          add_ci_file(target)
        end

        Flow::Login.sign_in
        project.visit!

        EE::Resource::PipelineSubscriptions.fabricate_via_browser_ui! do |resource|
          resource.project_path = upstream_project.path_with_namespace
        end
      end

      after do
        runner.remove_via_api! if runner
      end

      it 'test something there' do
        upstream_project.visit!

        Resource::Tag.fabricate_via_api! do |tag|
          tag.project = upstream_project
          tag.ref = upstream_project.default_branch
          tag.name = tag_name
        end

        Flow::Pipeline.visit_latest_pipeline
        sleep 45
      end

      private

      def add_ci_file(project)
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
                    script: echo DONE!
                YAML
              }
            ]
          )
        end
      end
    end
  end
end
