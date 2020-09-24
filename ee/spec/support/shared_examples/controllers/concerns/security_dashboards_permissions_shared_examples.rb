# frozen_string_literal: true

RSpec.shared_examples SecurityDashboardsPermissions do
  include ApiHelpers

  let(:security_dashboard_user) { create(:user) }

  before do
    sign_in(security_dashboard_user)
  end

  describe 'access for all actions' do
    context 'when security dashboard feature is disabled' do
      it 'returns 404' do
        stub_licensed_features(security_dashboard: false)

        security_dashboard_action

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when security dashboard feature is enabled' do
      before do
        stub_licensed_features(security_dashboard: true)
      end

      context 'when user has guest access' do
        it 'denies access' do
          vulnerable.add_guest(security_dashboard_user)

          security_dashboard_action

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end

      context 'when user has developer access' do
        it 'grants access' do
          vulnerable.add_developer(security_dashboard_user)

          security_dashboard_action

          expect(response).to have_gitlab_http_status(:ok)
        end
      end
    end
  end
end
