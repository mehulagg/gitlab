# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::StatusChecks do
  describe 'POST :id/:merge_requests/:merge_request_iid/status_check_responses' do
    let!(:project) { create(:project) }
    let!(:rule) { create(:external_approval_rule, project: project) }
    let!(:merge_request) { create(:merge_request, source_project: project) }
    let!(:project_maintainer) { create(:user) }
    let(:sha) { merge_request.source_branch_sha }
    let(:current_user) { project_maintainer }

    subject { post api("/projects/#{project.id}/merge_requests/#{merge_request.iid}/status_check_responses", current_user), params: { external_approval_rule_id: rule.id, sha: sha } }

    context 'feature flag is disabled' do
      before do
        stub_feature_flags(ff_compliance_approval_gates: false)
      end

      it 'returns a not found error' do
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when current_user has access' do
      before do
        project.add_user(project_maintainer, :maintainer)
      end

      it 'returns a 201' do
        subject

        expect(response).to have_gitlab_http_status(:created)
      end

      it 'returns the approval rule as JSON' do
        subject

        expect(json_response.keys).to contain_exactly('id', 'merge_request', 'external_approval_rule')
      end

      it 'creates new external approval with correct attributes' do
        expect { subject }.to change { MergeRequests::StatusCheckResponse.count }.by 1
      end

      context 'when sha is not the source branch HEAD' do
        let(:sha) { 'notarealsha' }

        it 'does not create a new approval' do
          expect { subject }.not_to change { MergeRequests::StatusCheckResponse.count }
        end

        it 'returns a conflict error' do
          subject

          expect(response).to have_gitlab_http_status(:conflict)
        end
      end

      context 'when user is not authenticated' do
        let(:current_user) { nil }

        it 'returns an unauthorized status' do
          subject

          expect(response).to have_gitlab_http_status(:unauthorized)
        end
      end
    end

    using RSpec::Parameterized::TableSyntax

    where(:access_level, :http_status) do
      :reporter | :forbidden
      :developer | :created
      :maintainer | :created
    end

    with_them do
      before do
        project.add_user(current_user, access_level)
      end

      it 'returns the correct status' do
        subject

        expect(response).to have_gitlab_http_status(http_status)
      end
    end
  end
end
