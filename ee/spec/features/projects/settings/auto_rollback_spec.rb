# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Automatic Deployment Rollbacks' do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }

  before do
    stub_licensed_features(auto_rollback: true)

    sign_in(user)
  end

  context 'logged in as developer' do
    before do
      project.add_developer(user)

      visit project_settings_ci_cd_path(project)
    end

    it 'does not have access to Automatic Deployment Rollbacks settings' do
      expect(page).to have_gitlab_http_status(:not_found)
    end
  end

  context 'logged in as a maintainer' do
    before do
      project.add_maintainer(user)

      visit project_settings_ci_cd_path(project)
    end

    it 'has access to Automatic Deployment Rollbacks settings' do
      expect(page).to have_gitlab_http_status(:ok)
    end

    it 'sees instance enabled badge' do
      visit group_settings_ci_cd_path(group)

      page.within '#auto-rollback-settings' do
        expect(page).to have_content('instance enabled')
      end
    end
  end
end
