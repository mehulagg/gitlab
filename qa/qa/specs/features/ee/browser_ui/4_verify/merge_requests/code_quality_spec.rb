# frozen_string_literal: true

require 'pathname'

module QA
  context 'Verify', :docker do
    describe 'Code Quality Reports in a Merge Request' do
      after do
        Service::DockerRun::GitlabRunner.new(@executor).remove!
      end

      before do
        @executor = "qa-runner-#{Time.now.to_i}"

        Flow::Login.sign_in

        @project = Resource::Project.fabricate_via_api! do |p|
          p.name = Runtime::Env.auto_devops_project_name || 'project-with-codequality'
          p.description = 'Project with Code Quality'
          p.auto_devops_enabled = false
          p.initialize_with_readme = true
        end

        Resource::Runner.fabricate! do |runner|
          runner.project = @project
          runner.name = @executor
          runner.tags = %w[qa test]
        end

        # Push fixture to generate Code Quality reports
        @source = Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = @project
          push.directory = Pathname
            .new(__dir__)
            .join('../../../../../ee/fixtures/code_quality_reports')
          push.commit_message = 'Initialize app with code quality reports'
          push.branch_name = 'code-quality-mr'
        end

        merge_request = Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.project = @project
          mr.source_branch = 'secure-mr'
          mr.target_branch = 'master'
          mr.source = @source
          mr.target = 'master'
          mr.target_new_branch = false
        end

        @project.visit!
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:click_on_latest_pipeline)
        wait_for_job "codequality"

        merge_request.visit!
      end

      it 'displays the Code Quality reports in the merge request' do
        Page::MergeRequest::Show.perform do |merge_request|
          expect(merge_request).to have_code_quality_report
        end
      end
    end
  end
end