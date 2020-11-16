# frozen_string_literal: true

module QA
  RSpec.describe 'Secure', :runner do
    describe 'Security Dashboard in a Project' do
      let(:vulnerability_name) { "CVE-2017-18269 in glibc" }
      let(:vulnerability_description) { "Short description to match in specs" }

      before(:all) do
        @executor = "qa-runner-#{Time.now.to_i}"

        Flow::Login.sign_in

        @project = Resource::Project.fabricate_via_api! do |p|
          p.name = Runtime::Env.auto_devops_project_name || 'project-with-secure'
          p.description = 'Project with Secure'
          p.auto_devops_enabled = false
          p.initialize_with_readme = true
        end

        @runner = Resource::Runner.fabricate! do |runner|
          runner.project = @project
          runner.name = @executor
          runner.tags = %w[qa test]
        end

        # Push fixture to generate Secure reports
        @source = Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = @project
          push.directory = Pathname
            .new(__dir__)
            .join('../../../../../ee/fixtures/secure_premade_reports')
          push.commit_message = 'Create Secure compatible application to serve premade reports'
          push.branch_name = 'secure-mr'
        end

        @merge_request = Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.project = @project
          mr.source_branch = 'secure-mr'
          mr.target_branch = 'master'
          mr.source = @source
          mr.target = 'master'
          mr.target_new_branch = false
        end

        @merge_request.visit!
        Page::MergeRequest::Show.perform do |merge_request|
          # Give time for the runner on Staging to complete pipeline
          Support::Retrier.retry_until(max_attempts: 5, sleep_interval: 5, reload_page: merge_request) do
            merge_request.has_pipeline_status?(/Pipeline #\d+ passed/)
          end
          merge_request.merge!
        end
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:wait_for_latest_pipeline_success)
      end

      after(:all) do
        @runner.remove_via_api!
      end

      it 'shows vulnerability details', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/949' do
        Flow::Login.sign_in_unless_signed_in
        @project.visit!
        Page::Project::Menu.perform(&:click_on_vulnerability_report)

        EE::Page::Project::Secure::SecurityDashboard.perform do |security_dashboard|
          expect(security_dashboard).to have_vulnerability(description: vulnerability_name)
          security_dashboard.click_vulnerability(description: vulnerability_name)
        end

        EE::Page::Project::Secure::VulnerabilityDetails.perform do |vulnerability_details|
          expect(vulnerability_details).to have_component(component_name: :vulnerability_header)
          expect(vulnerability_details).to have_component(component_name: :vulnerability_details)
          expect(vulnerability_details).to have_vulnerability_title(title: vulnerability_name)
          expect(vulnerability_details).to have_vulnerability_description(description: vulnerability_description)
          expect(vulnerability_details).to have_component(component_name: :vulnerability_footer)
        end
      end
    end
  end
end
