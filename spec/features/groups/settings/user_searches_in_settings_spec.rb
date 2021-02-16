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

    it_behaves_like 'can search settings with feature flag check', 'Naming', 'Permissions', 'Badges'
  end

  context 'in Repository page' do
    before do
      visit project_settings_ci_cd_path(project)
    end

    it_behaves_like 'can search settings', 'Deploy tokens', 'Default initial branch name'
  end

  context 'in CI/CD page' do
    before do
      visit project_settings_ci_cd_path(project)
    end

    it_behaves_like 'can search settings', 'General pipelines', 'Auto DevOps', 'Variables'
  end
end
