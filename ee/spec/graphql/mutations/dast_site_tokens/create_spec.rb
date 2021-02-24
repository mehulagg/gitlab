# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::DastSiteTokens::Create do
  let(:group) { create(:group) }
  let(:project) { create(:project, group: group) }
  let(:user) { create(:user) }
  let(:full_path) { project.full_path }
  let(:target_url) { generate(:url) }
  let(:dast_site_token) { DastSiteToken.find_by!(project: project, token: uuid) }
  let(:uuid) { '0000-0000-0000-0000' }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
  end

  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }

  describe '#resolve' do
    subject do
      mutation.resolve(
        full_path: full_path,
        target_url: target_url
      )
    end

    context 'when on demand scan feature is enabled' do
      context 'when the project does not exist' do
        let(:full_path) { 'project-does-not-exist' }

        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user can run a dast scan' do
        before do
          project.add_developer(user)
        end

        it 'returns the dast_site_token id' do
          expect(subject[:id]).to eq(dast_site_token.to_global_id)
        end

        it 'returns the dast_site_token status' do
          expect(subject[:status]).to eq('pending')
        end

        it 'returns the dast_site_token token' do
          expect(subject[:token]).to eq(SecureRandom.uuid)
        end

        context 'when the associated dast_site_validation has been validated' do
          it 'returns the correct status' do
            create(:dast_site_validation, dast_site_token: subject[:id].find, state: :failed)

            result = mutation.resolve(
              full_path: full_path,
              target_url: target_url
            )

            expect(result[:status]).to eq('failed')
          end
        end
      end
    end
  end
end
