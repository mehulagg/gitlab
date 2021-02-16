# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User searches project settings', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, namespace: user.namespace, path: 'gitlab', name: 'sample') }

  before do
    sign_in(user)
  end

  context 'in general settings page' do
    let(:visit_path) { edit_project_path(project) }

    it_behaves_like 'can search settings with feature flag check', 'Naming', 'Visibility', 'Merge requests'
  end

  context 'in Repository page' do
    before do
      visit project_settings_ci_cd_path(project)
    end

    it_behaves_like 'can search settings', 'Default branch', 'Mirroring repositories', 'Deploy keys'
  end

  context 'in CI/CD page' do
    before do
      visit project_settings_ci_cd_path(project)
    end

    it_behaves_like 'can search settings', 'General pipelines', 'Auto DevOps', 'Runners'
  end

  context 'in Operations page' do
    before do
      visit project_settings_operations_path(project)
    end

    it_behaves_like 'can search settings', 'Alerts', 'Incidents', 'Error tracking'
  end
end
