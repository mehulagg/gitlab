# frozen_string_literal: true

require 'pathname'

module QA
  RSpec.describe 'Secure', :runner do
    let(:approved_license_name) { "MIT License" }
    let(:denied_license_name) { "Apache License 2.0" }

    describe 'License Compliance page' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-secure'
          project.description = 'Project with Secure'
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.project = project
          runner.name = "runner-for-#{project.name}"
          runner.tags = %w[qa test]
        end
      end

      after do
        runner&.remove_via_api!
      end

      before do
        Flow::Login.sign_in_unless_signed_in
      end

      it 'has empty state', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1128' do
        project.visit!
        Page::Project::Menu.perform(&:click_on_license_compliance)

        EE::Page::Project::Secure::LicenseCompliance.perform do |license_compliance|
          expect(license_compliance).to have_empty_state_decription('The license list details information about the licenses used within your project.')
          expect(license_compliance).to have_link('More Information', href: %r{\/help\/user\/compliance\/license_compliance\/index})
        end
      end

      context 'approve or deny licenses' do
        before do
          Flow::Login.sign_in

          # Push fixture to generate Secure reports
          Resource::Repository::ProjectPush.fabricate! do |project_push|
            project_push.project = project
            project_push.directory = Pathname
                                         .new(__dir__)
                                         .join('../../../../../ee/fixtures/secure_license_files')
            project_push.commit_message = 'Create Secure compatible application to serve premade reports'
          end.project.visit!

          Flow::Pipeline.wait_for_latest_pipeline(pipeline_condition: 'succeeded')
        end

        it 'can approve a license in the license compliance page', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/964' do
          project.visit!
          Page::Project::Menu.perform(&:click_on_license_compliance)

          EE::Page::Project::Secure::LicenseCompliance.perform do |license_compliance|
            license_compliance.open_tab
            license_compliance.approve_license approved_license_name

            expect(license_compliance).to have_approved_license approved_license_name
          end
        end

        it 'can deny a license in the settings page', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/963' do
          project.visit!
          Page::Project::Menu.perform(&:click_on_license_compliance)

          EE::Page::Project::Secure::LicenseCompliance.perform do |license_compliance|
            license_compliance.open_tab
            license_compliance.deny_license denied_license_name

            expect(license_compliance).to have_denied_license denied_license_name
          end
        end
      end
    end

    describe 'License Compliance pipeline reports', quarantine: { issue: 'https://gitlab.com/gitlab-org/gitlab/-/issues/241448', type: :bug } do
      let(:executor) {"qa-runner-#{Time.now.to_i}"}

      after do
        @runner.remove_via_api!
      end

      before do
        @executor = "qa-runner-#{Time.now.to_i}"

        Flow::Login.sign_in

        @project = Resource::Project.fabricate_via_api! do |project|
          project.name = Runtime::Env.auto_devops_project_name || 'project-with-secure'
          project.description = 'Project with Secure'
        end

        @runner = Resource::Runner.fabricate! do |runner|
          runner.project = @project
          runner.name = executor
          runner.tags = %w[qa test]
        end

        # Push fixture to generate Secure reports
        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = project
          project_push.directory = Pathname
                                       .new(__dir__)
                                       .join('../../../../../ee/fixtures/secure_premade_reports')
          project_push.commit_message = 'Create Secure compatible application to serve premade reports'
        end

        Flow::Login.sign_in
        project.visit!
        Flow::Pipeline.wait_for_latest_pipeline(pipeline_condition: 'succeeded')
        Page::Project::Menu.perform(&:click_on_license_compliance)
      end

      it 'can approve and deny licenses in the pipeline', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1272' do
        EE::Page::Project::Secure::LicenseCompliance.perform do |license_compliance|
          license_compliance.open_tab
          license_compliance.approve_license approved_license_name
          license_compliance.deny_license denied_license_name
        end

        project.visit!
        Flow::Pipeline.visit_latest_pipeline

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_on_licenses
          expect(pipeline).to have_approved_license approved_license_name
          expect(pipeline).to have_denied_license denied_license_name
        end
      end
    end
  end
end
