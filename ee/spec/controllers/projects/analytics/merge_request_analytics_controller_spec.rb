# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Analytics::MergeRequestAnalyticsController do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:feature_flag_name) { Gitlab::Analytics::PROJECT_MERGE_REQUEST_ANALYTICS_FEATURE_FLAG }
  let_it_be(:feature_name) { :project_merge_request_analytics }

  before do
    sign_in(current_user)

    stub_feature_flags(feature_flag_name => true)
    stub_licensed_features(feature_name => true)
  end

  describe 'GET show' do
    subject { get :show, params: { namespace_id: group, project_id: project } }

    before do
      group.add_maintainer(current_user)
    end

    it { is_expected.to be_successful }

    context 'when license is missing' do
      before do
        stub_licensed_features(feature_name => false)
      end

      it { is_expected.to have_gitlab_http_status(:not_found) }
    end

    context 'when feature flag is off' do
      before do
        stub_feature_flags(feature_flag_name => false)
      end

      it { is_expected.to have_gitlab_http_status(:not_found) }
    end

    context 'when the user has no access to the group' do
      before do
        current_user.project_authorizations.delete_all
      end

      it { is_expected.to have_gitlab_http_status(:not_found) }
    end
  end
end
