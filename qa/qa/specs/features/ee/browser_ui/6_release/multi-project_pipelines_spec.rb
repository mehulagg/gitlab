# frozen_string_literal: true

require 'securerandom'

module QA
  RSpec.describe 'Release' do
    describe 'Multi-project pipelines' do
      let(:upstream_project_name) { "upstream-project-#{SecureRandom.hex(8)}" }
      let(:downstream_project_name) { "downstream-project-#{SecureRandom.hex(8)}" }
      let(:upstream_project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = upstream_project_name
        end
      end

      let(:downstream_project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = downstream_project_name
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate_via_api! do |runner|
          runner.project = upstream_project
          runner.token = upstream_project.group.sandbox.runners_token
          runner.name = upstream_project_name
          runner.tags = [upstream_project_name]
        end
      end

      before do
        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = upstream_project
          project_push.file_name = '.gitlab-ci.yml'
          project_push.commit_message = 'Add .gitlab-ci.yml'
          project_push.file_content = <<~CI
            stages:
             - test
             - deploy

            job1:
              stage: test
              tags: ["#{upstream_project_name}"]
              script: echo "done"

            staging:
              stage: deploy
              trigger:
                project: #{downstream_project.path_with_namespace}
                strategy: depend
          CI
        end

        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = downstream_project
          project_push.file_name = '.gitlab-ci.yml'
          project_push.commit_message = 'Add .gitlab-ci.yml'
          project_push.file_content = <<~CI
            downstream_job:
              stage: test
              tags: ["#{upstream_project_name}"]
              script: echo "done"
          CI
        end

        Flow::Login.sign_in

        Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.project = upstream_project
          merge_request.target_new_branch = false
        end.visit!
      end

      after do
        runner.remove_via_api!
      end

      it 'creates a multi-project pipeline', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/560' do
        Page::MergeRequest::Show.perform do |show|
          pipeline_passed = show.has_pipeline_status?('passed')
          expect(pipeline_passed).to be_truthy, "The pipeline did not pass."

          show.click_pipeline_link
        end

        Page::Project::Pipeline::Show.perform do |show|
          expect(show).to have_passed
          expect(show).not_to have_job("downstream_job")

          show.expand_child_pipeline

          expect(show).to have_job("downstream_job")
        end
      end
    end
  end
end
