# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::DastSiteProfiles::Update do
  let(:group) { create(:group) }
  let(:project) { create(:project, group: group) }
  let(:user) { create(:user) }
  let(:full_path) { project.full_path }
  let!(:dast_site_profile) { create(:dast_site_profile, project: project) }

  let(:new_profile_name) { SecureRandom.hex }
  let(:new_target_url) { generate(:url) }

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
        target_url: new_target_url
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

        it 'updates the dast_site_profile' do
          dast_site_profile = subject[:id].find

          aggregate_failures do
            expect(dast_site_profile.name).to eq(new_profile_name)
            expect(dast_site_profile.dast_site.url).to eq(new_target_url)
          end
        end
      end
    end
  end
end
