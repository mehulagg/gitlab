# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JwtController do
  context 'authenticating against container registry' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }
    let(:project) { create(:project, :private, group: group) }
    let(:scope) { "repository:#{project.full_path}:pull" }
    let(:service_name) { 'container_registry' }
    let(:headers) { { authorization: credentials(user.username, user.password) } }
    let(:parameters) { { account: user.username, client_id: 'docker', offline_token: true, service: service_name, scope: scope } }

    before do
      stub_container_registry_config(enabled: true, issuer: 'gitlab-issuer', key: 'spec/fixtures/x509_certificate_pk.key')
      project.add_reporter(user)
    end

    context 'when Group SSO is enforced' do
      let!(:saml_provider) { create(:saml_provider, enforced_sso: true, group: group) }
      let!(:identity) { create(:group_saml_identity, saml_provider: saml_provider, user: user) }

      it 'allows access' do
        get '/jwt/auth', params: parameters, headers: headers

        expect(response).to have_gitlab_http_status(:ok)
        expect(token_response['access']).to be_present
        expect(token_access['actions']).to eq ['pull']
        expect(token_access['type']).to eq 'repository'
        expect(token_access['name']).to eq project.full_path
      end
    end
  end

  def credentials(login, password)
    ActionController::HttpAuthentication::Basic.encode_credentials(login, password)
  end

  def token_response
    JWT.decode(json_response['token'], nil, false).first
  end

  def token_access
    token_response['access']&.first
  end
end
