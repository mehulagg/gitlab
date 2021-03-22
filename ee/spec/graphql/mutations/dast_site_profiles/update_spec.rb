# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::DastSiteProfiles::Update do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project) }

  let(:full_path) { project.full_path }
  let(:new_profile_name) { SecureRandom.hex }
  let(:new_target_url) { generate(:url) }
  let(:new_excluded_urls) { ["#{new_target_url}/signout"] }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }

  describe '#resolve' do
    subject do
      mutation.resolve(
        full_path: full_path,
        id: dast_site_profile.to_global_id,
        profile_name: new_profile_name,
        target_url: new_target_url,
        excluded_urls: new_excluded_urls,
        request_headers: 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0',
        auth: {
          enabled: true,
          url: "#{new_target_url}/login",
          username_field: 'session[username]',
          password_field: 'session[password]',
          username: generate(:email),
          password: SecureRandom.hex
        }
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

        it 'updates the dast_site_profile', :aggregate_failures do
          dast_site_profile = subject[:id].find

          expect(dast_site_profile.name).to eq(new_profile_name)
          expect(dast_site_profile.dast_site.url).to eq(new_target_url)
          expect(dast_site_profile.reload.excluded_urls).to eq(new_excluded_urls)
        end

        context 'when the feature flag security_dast_site_profiles_additional_fields is disabled' do
          it 'does not set the branch_name' do
            stub_feature_flags(security_dast_site_profiles_additional_fields: false)

            dast_site_profile = subject[:id].find

            expect(dast_site_profile.reload.excluded_urls).not_to eq(new_excluded_urls)
          end
        end
      end
    end
  end
end
