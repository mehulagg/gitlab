# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraConnect::InstallationsController do
  let_it_be(:installation) { create(:jira_connect_installation) }

  describe '#index' do
    before do
      get :index, params: { jwt: jwt }
    end

    context 'without JWT' do
      let(:jwt) { nil }

      it 'returns 403' do
        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'with valid JWT' do
      let(:qsh) { Atlassian::Jwt.create_query_string_hash('https://gitlab.test/subscriptions', 'GET', 'https://gitlab.test') }
      let(:jwt) { Atlassian::Jwt.encode({ iss: installation.client_key, qsh: qsh }, installation.shared_secret) }

      it 'returns 200' do
        expect(response).to have_gitlab_http_status(:ok)
      end
    end
  end

  xdescribe '#update' do
    before do
      get :index, params: { jwt: jwt }
    end

    context 'without JWT' do
      let(:jwt) { nil }

      it 'returns 403' do
        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'with valid JWT' do
      let(:qsh) { Atlassian::Jwt.create_query_string_hash('https://gitlab.test/subscriptions', 'GET', 'https://gitlab.test') }
      let(:jwt) { Atlassian::Jwt.encode({ iss: installation.client_key, qsh: qsh }, installation.shared_secret) }

      it 'returns 200' do
        expect(response).to have_gitlab_http_status(:ok)
      end

      it 'removes X-Frame-Options to allow rendering in iframe' do
        expect(response.headers['X-Frame-Options']).to be_nil
      end
    end
  end
end
