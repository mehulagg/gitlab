# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::DastSiteProfiles::Create do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user) }

  let(:full_path) { project.full_path }
  let(:profile_name) { SecureRandom.hex }
  let(:target_url) { generate(:url) }
  let(:excluded_urls) { ["#{target_url}/signout"] }
  let(:request_headers) { 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0' }

  let(:auth) do
    {
      enabled: true,
      url: "#{target_url}/login",
      username_field: 'session[username]',
      password_field: 'session[password]',
      username: generate(:email),
      password: SecureRandom.hex
    }
  end

  let(:dast_site_profile) { DastSiteProfile.find_by(project: project, name: profile_name) }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }

  describe '#resolve' do
    subject do
      mutation.resolve(
        full_path: full_path,
        profile_name: profile_name,
        target_url: target_url,
        excluded_urls: excluded_urls,
        request_headers: request_headers,
        auth: auth
      )
    end

    context 'when on demand scan feature is enabled' do
      context 'when the project does not exist' do
        let(:full_path) { SecureRandom.hex }

        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user can run a dast scan' do
        before do
          project.add_developer(user)
        end

        it 'returns the dast_site_profile id' do
          expect(subject[:id]).to eq(dast_site_profile.to_global_id)
        end

        it 'calls the dast_site_profile creation service' do
          service = double(DastSiteProfiles::CreateService)
          result = double('result', success?: false, errors: [])

          service_params = {
            name: profile_name,
            target_url: target_url,
            excluded_urls: excluded_urls,
            request_headers: request_headers,
            auth_enabled: auth[:enabled],
            auth_url: auth[:url],
            auth_username_field: auth[:username_field],
            auth_password_field: auth[:password_field],
            auth_username: auth[:username],
            auth_password: auth[:password]
          }

          expect(DastSiteProfiles::CreateService).to receive(:new).and_return(service)
          expect(service).to receive(:execute).with(service_params).and_return(result)

          subject
        end

        context 'when the project name already exists' do
          it 'returns an error' do
            subject

            response = mutation.resolve(
              full_path: full_path,
              profile_name: profile_name,
              target_url: target_url
            )

            expect(response[:errors]).to include('Name has already been taken')
          end
        end

        context 'when excluded_urls is supplied as a param' do
          context 'when the feature flag security_dast_site_profiles_additional_fields is disabled' do
            before do
              stub_feature_flags(security_dast_site_profiles_additional_fields: false)
            end

            it 'does not set the request_headers or the password' do
              subject

              expect(dast_site_profile.secret_variables).to be_empty
            end

            it 'does not set non-secret auth fields' do
              subject

              expect(dast_site_profile).to have_attributes(
                auth_enabled: false,
                auth_url: nil,
                auth_username_field: nil,
                auth_password_field: nil,
                auth_username: nil
              )
            end
          end

          context 'when the feature flag security_dast_site_profiles_additional_fields is enabled' do
            it 'sets the excluded_urls' do
              subject

              expect(dast_site_profile.excluded_urls).to eq(excluded_urls)
            end

            it 'sets the request_headers' do
              subject

              expect(dast_site_profile.secret_variables.map(&:key)).to include(Dast::SiteProfileSecretVariable::REQUEST_HEADERS)
            end

            it 'sets the password' do
              subject

              expect(dast_site_profile.secret_variables.map(&:key)).to include(Dast::SiteProfileSecretVariable::PASSWORD)
            end

            it 'sets non-secret auth fields' do
              subject

              expect(dast_site_profile).to have_attributes(
                auth_enabled: auth[:enabled],
                auth_url: auth[:url],
                auth_username_field: auth[:username_field],
                auth_password_field: auth[:password_field],
                auth_username: auth[:username]
              )
            end
          end
        end
      end
    end
  end
end
