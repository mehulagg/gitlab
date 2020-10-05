# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Analytics::MergeRequestAnalyticsController do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create :group }
  let_it_be(:feature_name) { :group_merge_request_analytics }

  before do
    sign_in(current_user)

    stub_licensed_features(feature_name => true)
  end

  describe 'GET #show' do
    subject { get :show, params: { group_id: group } }

    before do
      group.add_maintainer(current_user)
    end

    it { is_expected.to be_successful }

    it_behaves_like 'tracking unique visits', :show do
      let(:request_params) { { group_id: group } }
      let(:target_id) { 'g_analytics_merge_request' }
    end

    context 'when license is missing' do
      before do
        stub_licensed_features(feature_name => false)
      end

      it { is_expected.to have_gitlab_http_status(:forbidden) }
    end

    context 'when the user has no access to the group' do
      before do
        current_user.group_members.delete_all
      end

      it { is_expected.to have_gitlab_http_status(:forbidden) }
    end
  end
end
