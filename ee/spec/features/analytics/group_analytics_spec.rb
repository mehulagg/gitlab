# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GroupAnalytics' do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let(:path) { group_path(group) }

  before do
    stub_licensed_features(group_activity_analytics: true)

    group.add_developer(user)
    sign_in(user)
  end

  context 'when the feature is enabled' do
    it 'renders the container' do
      visit path

      expect(page).to have_css('#js-group-activity')
    end
  end

  context 'when the feature is disabled' do
    before do
      stub_feature_flags(group_activity_analytics: false)
    end

    it 'does not render the container' do
      visit path

      expect(page).not_to have_css('#js-group-activity')
    end
  end
end
