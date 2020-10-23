# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Security::ComplianceDashboardsController do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  before do
    sign_in(user)
  end

  describe 'GET show' do
    subject { get :show, params: { group_id: group.to_param } }

    context 'when compliance dashboard feature is enabled' do
      before do
        stub_licensed_features(group_level_compliance_dashboard: true)
      end

      context 'and user is allowed to access group compliance dashboard' do
        before do
          group.add_owner(user)
        end

        it { is_expected.to have_gitlab_http_status(:success) }

        context 'when there are no merge requests' do
          it 'does not receive merge request collection' do
            subject
            expect(assigns(:merge_requests)).to be_empty
          end
        end

        context 'when there are merge requests' do
          let(:project) { create(:project, namespace: group) }

          let(:mr_1) { create(:merge_request, source_project: project, state: :merged) }
          let(:mr_2) { create(:merge_request, source_project: project, source_branch: 'A', state: :merged) }

          before do
            create(:event, :merged, project: project, target: mr_1, author: user)
          end

          it 'receives merge requests collection' do
            subject
            expect(assigns(:merge_requests)).not_to be_empty
          end
        end

        it_behaves_like 'tracking unique visits', :show do
          let(:request_params) { { group_id: group.to_param } }
          let(:target_id) { 'g_compliance_dashboard' }
        end
      end

      context 'when user is not allowed to access group compliance dashboard' do
        it { is_expected.to have_gitlab_http_status(:not_found) }
      end
    end

    context 'when compliance dashboard feature is disabled' do
      it { is_expected.to have_gitlab_http_status(:not_found) }
    end
  end
end
