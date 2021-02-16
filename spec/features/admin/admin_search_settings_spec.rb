# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin searches application settings', :js do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:application_settings) { create(:application_setting) }

  before do
    sign_in(admin)
    gitlab_enable_admin_mode_sign_in(admin)
  end

  context 'in appearances page' do
    before do
      visit(admin_appearances_path)
    end

    it_behaves_like 'cannot search settings'
  end

  context 'in ci/cd settings page' do
    let(:visit_path) { ci_cd_admin_application_settings_path }

    it_behaves_like 'can search settings with feature flag check', 'Variables', 'Package Registry'
  end
end
