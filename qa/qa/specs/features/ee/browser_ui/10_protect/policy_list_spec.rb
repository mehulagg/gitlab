# frozen_string_literal: true

module QA
  RSpec.describe 'Protect', :runner do
    let(:approved_license_name) { "MIT License" }
    let(:denied_license_name) { "Apache License 2.0" }

    describe 'Threat Monitoring Policy List page' do
      before(:all) do
        @executor = "qa-runner-#{Time.now.to_i}"

        Flow::Login.sign_in

        @project = Resource::Project.fabricate_via_api! do |p|
          p.name = Runtime::Env.auto_devops_project_name || 'project-with-protect'
          p.description = 'Project with Protect'
          p.auto_devops_enabled = false
          p.initialize_with_readme = true
        end

        @project.visit!
      end

      it 'can load Threat Monitoring page and view the policy alert list', testcase: 'I do not know what to put here' do
        Page::Project::Menu.perform(&:click_on_threat_monitoring)

        EE::Page::Project::ThreatMonitoring::AlertsList.perform do |alerts_list|
          expect(alerts_list).to have_alerts_tab have_alerts_list
        end
      end
    end
  end
end
