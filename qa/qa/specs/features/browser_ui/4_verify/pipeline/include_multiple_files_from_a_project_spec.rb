# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify', :runner, :requires_admin do
    describe "Include multiple files from a project" do
      # let(:feature_flag) { :ci_manual_bridges }
      let(:executor) { "qa-runner-#{Faker::Alphanumeric.alphanumeric(8)}" }

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-pipeline-1'
        end
      end

      let(:other_project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-pipeline-2'
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.project = project
          runner.name = executor
          runner.tags = [executor]
        end
      end

      before do
        # Runtime::Feature.enable(feature_flag)
        Flow::Login.sign_in
        add_included_files
        add_main_ci_file
        project.visit!
        view_the_last_pipeline
      end

      after do
        # Runtime::Feature.disable(feature_flag)
        runner.remove_via_api!
      end

      it 'runs the pipeline with composed config', testcase: 'TODO: fill here' do
        Page::Project::Pipeline::Show.perform do |parent_pipeline|
          # TODO: check there are builds
          # TODO: (optional) check the output of test is "echo test overridden"
        end
      end

      private

      def add_main_ci_file
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add config file'
          commit.add_files([main_ci_file])
        end
      end

      def add_included_files
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = other_project
          commit.commit_message = 'Add files'
          commit.add_files([included_file_1, included_file_2])
        end
      end

      def view_the_last_pipeline
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:wait_for_latest_pipeline_success)
        Page::Project::Pipeline::Index.perform(&:click_on_latest_pipeline)
      end

      def main_ci_file
        {
          file_path: '.gitlab-ci.yml',
          content: <<~YAML
            include:
              - project: #{other_project.full_path}
                file:
                  - file1.yml
                  - file2.yml

            build:
              stage: build
              tags: ["#{executor}"]
              script: echo build

            test:
              stage: test
              tags: ["#{executor}"]
              script: echo test
          YAML
        }
      end

      def included_file_1
        {
          file_path: 'file1.yml',
          content: <<~YAML
            test:
              stage: test
              tags: ["#{executor}"]
              script: echo test overridden
          YAML
        }
      end

      def included_file_2
        {
          file_path: 'file2.yml',
          content: <<~YAML
            deploy:
              stage: deploy
              tags: ["#{executor}"]
              script: echo deploy
          YAML
        }
      end
    end
  end
end
