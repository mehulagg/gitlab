# frozen_string_literal: true

require 'pathname'

module QA
  # https://gitlab.com/gitlab-org/gitlab/issues/37231
  # https://gitlab.com/gitlab-org/gitlab/issues/36822
  # https://gitlab.com/gitlab-org/gitlab/issues/36559
  context 'Secure', :docker, :quarantine do
    describe 'Security Reports in a Merge Request' do
      let(:sast_vuln_count) { 33 }
      let(:dependency_scan_vuln_count) { 4 }
      let(:container_scan_vuln_count) { 8 }
      let(:dast_vuln_count) { 4 }
      let(:vuln_name) { "Regular Expression Denial of Service in debug" }
      let(:remediable_vuln_name) { "Authentication bypass via incorrect DOM traversal and canonicalization in saml2-js" }

      after do
        Service::DockerRun::GitlabRunner.new(@executor).remove!

        Runtime::Feature.enable('job_log_json') if @job_log_json_flag_enabled
      end

      before do
        @executor = "qa-runner-#{Time.now.to_i}"

        # Handle WIP Job Logs flag - https://gitlab.com/gitlab-org/gitlab/issues/31162
        @job_log_json_flag_enabled = Runtime::Feature.enabled?('job_log_json')
        Runtime::Feature.disable('job_log_json') if @job_log_json_flag_enabled

        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_credentials)

        @project = Resource::Project.fabricate_via_api! do |p|
          p.name = Runtime::Env.auto_devops_project_name || 'project-with-secure'
          p.description = 'Project with Secure'
          p.auto_devops_enabled = false
          p.initialize_with_readme = true
        end

        Resource::Runner.fabricate! do |runner|
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
        wait_for_job "dast"

        merge_request.visit!
      end

      it 'displays the Security reports in the merge request' do
        Page::MergeRequest::Show.perform do |merge_request|
          expect(merge_request).to have_vulnerability_report
          expect(merge_request).to have_vulnerability_count

          merge_request.expand_vulnerability_report

          expect(merge_request).to have_sast_vulnerability_count_of(sast_vuln_count)
          expect(merge_request).to have_dependency_vulnerability_count_of(dependency_scan_vuln_count)
          expect(merge_request).to have_container_vulnerability_count_of(container_scan_vuln_count)
          expect(merge_request).to have_dast_vulnerability_count_of(dast_vuln_count)
        end
      end

      it 'can dismiss a vulnerability with a reason' do
        dismiss_reason = "Vulnerability not applicable"

        Page::MergeRequest::Show.perform do |merge_request|
          expect(merge_request).to have_vulnerability_report
          merge_request.dismiss_vulnerability_with_reason(vuln_name, dismiss_reason)
          merge_request.click_vulnerability(vuln_name)

          expect(merge_request).to have_opened_dismissed_vulnerability(dismiss_reason)
        end
      end

      it 'can create an issue from a vulnerability' do
        Page::MergeRequest::Show.perform do |merge_request|
          expect(merge_request).to have_vulnerability_report
          merge_request.create_vulnerability_issue(vuln_name)
        end

        Page::Project::Issue::Show.perform do |issue|
          expect(issue).to have_title("Investigate vulnerability: #{vuln_name}")
        end
      end

      it 'can create an auto-remediation MR' do
        Page::MergeRequest::Show.perform do |merge_request|
          expect(merge_request).to have_vulnerability_report
          merge_request.resolve_vulnerability_with_mr remediable_vuln_name

          # Context changes as resolve method creates new MR
          expect(merge_request).to have_title remediable_vuln_name
        end
      end

      def wait_for_job(job_name)
        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job(job_name)
        end
        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 600)
        end
      end
    end
  end
end
