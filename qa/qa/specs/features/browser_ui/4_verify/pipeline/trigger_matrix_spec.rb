# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify', :runner do
    describe "Trigger matrix" do
      let(:executor) { "qa-runner-#{Faker::Alphanumeric.alphanumeric(8)}" }

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-pipeline'
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
        Flow::Login.sign_in
        add_ci_files
        project.visit!
        Flow::Pipeline.visit_latest_pipeline(pipeline_condition: 'succeeded')
      end

      after do
        runner.remove_via_api!
      end

      it 'creates 4 trigger jobs and passes corresponding matrix variables', testcase: 'TODO' do
        Page::Project::Pipeline::Show.perform do |parent_pipeline|
          expect(parent_pipeline).to have_child_pipeline

          find("[data-qa-selector='child_pipeline'][title*='deploy: [ovh, app]'] [data-qa-selector='expand_pipeline_button']").click
          parent_pipeline.click_job('test_vars')

          Page::Project::Job::Show.perform do |show|
            expect(show.output).to have_content('ovh')
            expect(show.output).to have_content('app')
          end
        end
      end

      private

      def add_ci_files
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add parent and child pipelines CI files.'
          commit.add_files(
            [
              child_ci_file,
              parent_ci_file
            ]
          )
        end
      end

      def parent_ci_file
        {
          file_path: '.gitlab-ci.yml',
          content: <<~YAML
            test:
              stage: test
              script: echo test
              tags: ["#{executor}"]

            deploy:
              stage: deploy
              trigger:
                include: child.yml
                strategy: depend # just to check the whole status easiy
              parallel:
                matrix:
                  - PROVIDER: ovh
                    STACK: [monitoring, app]

          YAML
        }
      end

      def child_ci_file
        {
          file_path: 'child.yml',
          content: <<~YAML
            test_vars:
              script:
                - echo $PROVIDER
                - echo $STACK
              tags: ["#{executor}"]
          YAML
        }
      end
    end
  end
end
