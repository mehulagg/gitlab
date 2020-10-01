# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Security Configuration', :js do
  include DocsScreenshotHelpers

  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group) }

  before do
    page.driver.browser.manage.window.resize_to(1366, 1024)

    group.add_owner(user)
    sign_in(user)

    stub_licensed_features(security_dashboard: true)
    stub_feature_flags(security_auto_fix: true)
  end

  context 'suggested solutions settings' do
    it 'user/application_security/img/suggested_solutions_settings' do
      visit visit_project_security_configuration
      screenshot_area = find('.js-suggested-solutions-settings')
      scroll_to screenshot_area
      expect(screenshot_area).to have_content 'Suggested Solutions'
      set_crop_data(screenshot_area, 20)
    end
  end

  def visit_project_security_configuration
    project_security_configuration_path(project)
  end
end
