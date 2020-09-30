# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Alert management', :js do
  let_it_be(:project) { create(:project) }
  let_it_be(:alert) { create(:alert_management_alert, :resolved, :with_fingerprint, project: project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:role) { :developer }

  before do
    project.add_role(user, role)
    sign_in(user)
  end

  context 'when visiting the alert details page' do
    before do
      stub_feature_flags(enable_environment_path_in_alert_details: false)

      visit(details_project_alert_management_path(project, alert))
    end

    it('pushes the feature flag to the frontend') do
      expect(page.evaluate_script('window.gon.features.enableEnvironmentPathInAlertDetails')).to be(false)
    end
  end
end
