# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::GroupMergeRequestApprovalSettings do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:admin) }
  let_it_be(:setting) { create(:merge_request_approval_setting, namespace: group) }

  let(:url) { "/groups/#{group.id}/merge_request_approval_settings" }

  describe 'GET /groups/:id/merge_request_approval_settings' do
    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(group_merge_request_approval_settings_feature_flag: false)
      end

      it 'returns 404 status' do
        get api(url, user)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when feature flag is enabled' do
      before do
        stub_feature_flags(group_merge_request_approval_settings_feature_flag: true)
        stub_licensed_features(group_merge_request_approval_settings: true)
      end

      context 'when the user is authorised' do
        it 'returns 200 status' do
          get api(url, user)

          expect(response).to have_gitlab_http_status(:ok)
        end

        it 'matches the response schema' do
          get api(url, user)

          expect(response).to match_response_schema('public_api/v4/group_merge_request_approval_settings', dir: 'ee')
        end
      end

      context 'when the user is not authorised' do
        let_it_be(:user) { create(:user) }

        it 'returns 403 status' do
          get api(url, user)

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end
    end
  end
end
