# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Analytics::RepositoryAnalyticsController do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:feature_flag_name) { Gitlab::Analytics::GROUP_COVERAGE_REPORTS_FEATURE_FLAG }
  let_it_be(:feature_name) { :group_repository_analytics }

  before do
    sign_in(current_user)

    stub_feature_flags(feature_flag_name => true)
    stub_licensed_features(feature_name => true)
  end

  describe 'GET show' do
    subject { get :show, params: { group_id: group } }

    before do
      group.add_guest(current_user)
    end

    specify { is_expected.to have_gitlab_http_status(:success) }

    it 'tracks a pageview event in snowplow' do
      expect(Gitlab::Tracking).to receive(:event).with(
        'Groups::Analytics::RepositoryAnalyticsController',
        'view_group_repository_analytics',
        label: 'group_id',
        value: group.id
      )
      subject
    end

    context 'when license is missing' do
      before do
        stub_licensed_features(feature_name => false)
      end

      it { is_expected.to have_gitlab_http_status(:forbidden) }
    end

    context 'when feature flag is off' do
      before do
        stub_feature_flags(feature_flag_name => false)
      end

      it { is_expected.to have_gitlab_http_status(:not_found) }
    end

    context 'when the user has no access to the group' do
      before do
        current_user.group_members.delete_all
      end

      it { is_expected.to have_gitlab_http_status(:forbidden) }
    end
  end
end
