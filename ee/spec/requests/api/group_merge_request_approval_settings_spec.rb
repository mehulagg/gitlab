# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::GroupMergeRequestApprovalSettings do
  let_it_be_with_reload(:group) { create(:group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:setting) { create(:group_merge_request_approval_setting, group: group) }

  let(:url) { "/groups/#{group.id}/merge_request_approval_setting" }

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
        allow(Ability).to receive(:allowed?).and_call_original
        stub_feature_flags(group_merge_request_approval_settings_feature_flag: true)
      end

      context 'when the user is authorised' do
        before do
          allow(Ability).to receive(:allowed?)
            .with(user, :admin_merge_request_approval_settings, group)
            .and_return(true)
        end

        it 'returns 200 status with correct response body', :aggregate_failures do
          get api(url, user)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['allow_author_approval']).to eq(false)
          expect(json_response['allow_committer_approval']).to eq(false)
          expect(json_response['allow_overrides_to_approver_list_per_merge_request']).to eq(false)
          expect(json_response['retain_approvals_on_push']).to eq(false)
          expect(json_response['require_password_to_approve']).to eq(false)
        end

        it 'matches the response schema' do
          get api(url, user)

          expect(response).to match_response_schema('public_api/v4/group_merge_request_approval_settings', dir: 'ee')
        end

        context 'when the group does not have existing settings' do
          before do
            group.group_merge_request_approval_setting.delete
          end

          it 'returns in-memory default settings', :aggregate_failures do
            get api(url, user)

            expect(response).to have_gitlab_http_status(:ok)
            expect(json_response['allow_author_approval']).to eq(false)
          end
        end
      end

      context 'when the user is not authorised' do
        before do
          allow(Ability).to receive(:allowed?)
            .with(user, :admin_merge_request_approval_settings, group)
            .and_return(false)
        end

        it 'returns 403 status' do
          get api(url, user)

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end
    end
  end

  describe 'PUT /groups/:id/merge_request_approval_setting' do
    let(:params) { { allow_author_approval: true } }

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(group_merge_request_approval_settings_feature_flag: false)
      end

      it 'returns 404 status' do
        put api(url, user), params: params

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when feature flag is enabled' do
      before do
        allow(Ability).to receive(:allowed?).and_call_original
        stub_feature_flags(group_merge_request_approval_settings_feature_flag: true)
      end

      context 'when the user is authorised' do
        before do
          allow(Ability).to receive(:allowed?)
            .with(user, :admin_merge_request_approval_settings, group)
            .and_return(true)
        end

        it 'returns 200 status with correct response body', :aggregate_failures do
          put api(url, user), params: params

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['allow_author_approval']).to eq(true)
        end

        it 'matches the response schema' do
          put api(url, user), params: params

          expect(response).to match_response_schema('public_api/v4/group_merge_request_approval_settings', dir: 'ee')
        end

        context 'when update fails' do
          let(:params) { { allow_author_approval: nil } }

          it 'returns 400 status', :aggregate_failures do
            put api(url, user), params: params

            expect(response).to have_gitlab_http_status(:bad_request)
            expect(json_response['message']).to eq('allow_author_approval' => ['must be a boolean value'])
          end
        end

        context 'when invalid params' do
          let(:params) { {} }

          it 'returns 400 status with error message', :aggregate_failures do
            put api(url, user), params: params

            expect(response).to have_gitlab_http_status(:bad_request)
            expect(json_response['error']).to match(/at least one parameter must be provided/)
          end
        end
      end

      context 'when the user is not authorised' do
        before do
          allow(Ability).to receive(:allowed?)
            .with(user, :admin_merge_request_approval_settings, group)
            .and_return(false)
        end

        it 'returns 403 status' do
          put api(url, user), params: params

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end
    end
  end
end
