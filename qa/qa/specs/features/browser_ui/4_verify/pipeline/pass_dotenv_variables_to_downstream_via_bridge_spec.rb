# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify', :runner, :requires_admin do
    describe "Pass dotenv variables to downstream via bridge" do
      let(:feature_flag) { :ci_bridge_dependency_variables }
      let(:executor) { "qa-runner-#{Faker::Alphanumeric.alphanumeric(8)}" }

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-pipeline-1'
        end
      end

      let(:downstream_project) do
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
        Runtime::Feature.enable(feature_flag)
        Flow::Login.sign_in
        add_downstream_ci_file
        add_upstream_ci_file
        project.visit!
        view_the_last_pipeline
      end

      after do
        Runtime::Feature.disable(feature_flag)
        runner.remove_via_api!
      end

      it 'runs the pipeline with composed config', testcase: 'TODO: fill here' do
        Page::Project::Pipeline::Show.perform do |parent_pipeline|
          Support::Waiter.wait_until { parent_pipeline.has_child_pipeline? }
          parent_pipeline.expand_child_pipeline
          parent_pipeline.click_job('downstream_test')
        end

        Page::Project::Job::Show.perform do |show|
          expect(show).to have_passed(timeout: 360)
        end
      end

      private

      def add_downstream_ci_file
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = downstream_project
          commit.commit_message = 'Add config file'
          commit.add_files([downstream_ci_file])
        end
      end

      def add_upstream_ci_file
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add config file'
          commit.add_files([upstream_ci_file])
        end
      end

      def view_the_last_pipeline
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:wait_for_latest_pipeline_success)
        Page::Project::Pipeline::Index.perform(&:click_on_latest_pipeline)
      end

      def upstream_ci_file
        {
          file_path: '.gitlab-ci.yml',
          content: <<~YAML
            build:
              stage: build
              tags: ["#{executor}"]
              script: echo "MY_VAR=hello" >> variables.env
              artifacts:
                reports:
                  dotenv: variables.env

            trigger:
              stage: deploy
              tags: ["#{executor}"]
              variables:
                PASSED_MY_VAR: $MY_VAR
              trigger: #{downstream_project.full_path}
          YAML
        }
      end

      def downstream_ci_file
        {
          file_path: '.gitlab-ci.yml',
          content: <<~YAML
            downstream_test:
              stage: test
              tags: ["#{executor}"]
              script: '[ "$PASSED_MY_VAR" = hello ]; exit "$?"'
          YAML
        }
      end
    end
  end
end
