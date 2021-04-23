# frozen_string_literal: true

require 'pathname'

module QA
  RSpec.describe 'Secure', :runner do
    let(:approved_license_name) { "MIT License" }
    let(:denied_license_name) { "Apache License 2.0" }

    describe 'License Compliance page' do
      after(:all) do
        @runner.remove_via_api!
      end

      before(:all) do
        @executor = "qa-runner-#{Time.now.to_i}"

        Flow::Login.sign_in

        @project = Resource::Project.fabricate_via_api! do |project|
          project.name = Runtime::Env.auto_devops_project_name || 'project-with-secure'
          project.description = 'Project with Secure'
        end

        @runner = Resource::Runner.fabricate! do |runner|
          runner.project = @project
          runner.name = @executor
          runner.tags = %w[qa test]
        end

        # Push fixture to generate Secure reports
        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = @project
          project_push.directory = Pathname
                                       .new(__dir__)
                                       .join('../../../../../ee/fixtures/secure_license_files')
          project_push.commit_message = 'Create Secure compatible application to serve premade reports'
        end.project.visit!

        Flow::Pipeline.wait_for_latest_pipeline(pipeline_condition: 'succeeded')
      end

      before do
        Flow::Login.sign_in_unless_signed_in
      end

      it 'can approve a license in the license compliance page', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/964' do
        @project.visit!
        Page::Project::Menu.perform(&:click_on_license_compliance)

        EE::Page::Project::Secure::LicenseCompliance.perform do |license_compliance|
          license_compliance.open_tab
          license_compliance.approve_license approved_license_name

          expect(license_compliance).to have_approved_license approved_license_name
        end
      end

      it 'can deny a license in the settings page', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/963' do
        @project.visit!
        Page::Project::Menu.perform(&:click_on_license_compliance)

        EE::Page::Project::Secure::LicenseCompliance.perform do |license_compliance|
          license_compliance.open_tab
          license_compliance.deny_license denied_license_name

          expect(license_compliance).to have_denied_license denied_license_name
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
          project_push.project = @project
          project_push.directory = Pathname
                                       .new(__dir__)
                                       .join('../../../../../ee/fixtures/secure_premade_reports')
          project_push.commit_message = 'Create Secure compatible application to serve premade reports'
        end

        @project.visit!
        Flow::Pipeline.wait_for_latest_pipeline(pipeline_condition: 'succeeded')
        Page::Project::Menu.perform(&:click_on_license_compliance)
      end

      it 'can approve and deny licenses in the pipeline', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1767' do
        EE::Page::Project::Secure::LicenseCompliance.perform do |license_compliance|
          license_compliance.open_tab
          license_compliance.approve_license approved_license_name
          license_compliance.deny_license denied_license_name
        end

        @project.visit!
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
