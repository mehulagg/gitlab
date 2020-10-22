# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JwtController do
  describe '#auth' do
    let_it_be(:user) { create(:user) }
    let_it_be(:personal_access_token) { create(:personal_access_token, user: user) }
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, :private, group: group) }
    let_it_be(:group_deploy_token) { create(:deploy_token, :group, groups: [group]) }
    let_it_be(:project_deploy_token) { create(:deploy_token, :project, projects: [project]) }

    subject { get '/jwt/auth', params: params, headers: headers }

    context 'authenticating against container registry' do
      let_it_be(:scope) { "repository:#{project.full_path}:pull" }
      let_it_be(:service_name) { 'container_registry' }
      let(:headers) { { authorization: credentials(user.username, user.password) } }
      let(:params) { { account: user.username, client_id: 'docker', offline_token: true, service: service_name, scope: scope } }

      before do
        stub_container_registry_config(enabled: true, issuer: 'gitlab-issuer', key: 'spec/fixtures/x509_certificate_pk.key')
        project.add_reporter(user)
      end

      context 'when Group SSO is enforced' do
        let!(:saml_provider) { create(:saml_provider, enforced_sso: true, group: group) }
        let!(:identity) { create(:group_saml_identity, saml_provider: saml_provider, user: user) }

        it 'allows access' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(token_response['access']).to be_present
          expect(token_access['actions']).to eq ['pull']
          expect(token_access['type']).to eq 'repository'
          expect(token_access['name']).to eq project.full_path
        end
      end
    end

    context 'authenticating against dependency proxy' do
      let_it_be(:service_name) { 'dependency_proxy' }
      let(:headers) { { authorization: credentials(credential_user, credential_password) } }
      let(:params) { { account: credential_user, client_id: 'docker', offline_token: true, service: service_name } }

      before do
        stub_config(dependency_proxy: { enabled: true })
      end

      shared_examples 'with valid credentials' do
        it 'returns token successfully' do
          subject

          expect(response).to have_gitlab_http_status(:success)
          expect(json_response['token']).to be_present
        end
      end

      context 'with personal access token' do
        let(:credential_user) { nil }
        let(:credential_password) { personal_access_token.token }

        it_behaves_like 'with valid credentials'
      end

      context 'with user credentials token' do
        let(:credential_user) { user.username }
        let(:credential_password) { user.password }

        it_behaves_like 'with valid credentials'
      end

      context 'with group deploy token' do
        let(:credential_user) { group_deploy_token.username }
        let(:credential_password) { group_deploy_token.token }

        it_behaves_like 'with valid credentials'
      end

      context 'with project deploy token' do
        let(:credential_user) { project_deploy_token.username }
        let(:credential_password) { project_deploy_token.token }

        it_behaves_like 'with valid credentials'
      end

      context 'with invalid credentials' do
        let(:credential_user) { 'foo' }
        let(:credential_password) { 'bar' }

        it 'returns unauthorized' do
          subject

          expect(response).to have_gitlab_http_status(:unauthorized)
        end
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
