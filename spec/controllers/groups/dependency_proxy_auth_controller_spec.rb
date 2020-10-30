# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::DependencyProxyAuthController do
  include DependencyProxyHelpers

  describe 'GET #pre_request' do
    subject { get :pre_request }

    context 'without JWT' do
      it 'returns unauthorized with oauth realm' do
        subject

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(response.headers['WWW-Authenticate']).to eq DependencyProxy::Registry.authenticate_header
      end
    end

    context 'with JWT' do
      let_it_be(:user) { create(:user) }
      let(:jwt) { build_jwt(user) }
      let(:token_header) { "Bearer #{jwt.encoded}" }

      before do
        request.headers['HTTP_AUTHORIZATION'] = token_header
      end

      it { is_expected.to have_gitlab_http_status(:success) }
    end
  end
end
