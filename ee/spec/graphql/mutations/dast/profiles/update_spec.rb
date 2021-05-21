# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Dast::Profiles::Update do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }
  let_it_be(:dast_profile, reload: true) { create(:dast_profile, project: project) }
  let_it_be(:new_dast_site_profile) { create(:dast_site_profile, project: project) }
  let_it_be(:new_dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

  let(:dast_profile_gid) { dast_profile.to_global_id }
  let(:run_after_update) { false }

  let(:params) do
    {
      id: dast_profile_gid,
      name: SecureRandom.hex,
      description: SecureRandom.hex,
      branch_name: project.default_branch,
      dast_site_profile_id: global_id_of(new_dast_site_profile),
      dast_scanner_profile_id: global_id_of(new_dast_scanner_profile),
      run_after_update: run_after_update
    }
  end

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }

  describe '#resolve' do
    subject { mutation.resolve(**params.merge(full_path: project.full_path)) }

    shared_examples 'an unrecoverable failure' do |parameter|
      it 'raises an exception' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when the feature is licensed' do
      context 'when the project does not exist' do
        before do
          allow_next_instance_of(ProjectsFinder) do |finder|
            allow(finder).to receive(:execute).and_return(nil)
          end
        end

        it_behaves_like 'an unrecoverable failure'
      end

      context 'when the user cannot read the project' do
        it_behaves_like 'an unrecoverable failure'
      end

      context 'when the user can update a DAST profile' do
        before do
          project.add_developer(user)
        end

        it 'returns the profile' do
          expect(subject[:dast_profile]).to be_a(Dast::Profile)
        end

        it 'updates the profile' do
          subject

          updated_dast_profile = dast_profile.reload

          aggregate_failures do
            expect(global_id_of(updated_dast_profile.dast_site_profile)).to eq(params[:dast_site_profile_id])
            expect(global_id_of(updated_dast_profile.dast_scanner_profile)).to eq(params[:dast_scanner_profile_id])
            expect(updated_dast_profile.name).to eq(params[:name])
            expect(updated_dast_profile.description).to eq(params[:description])
            expect(updated_dast_profile.branch_name).to eq(params[:branch_name])
          end
        end

        context 'when run_after_update=true' do
          let(:run_after_update) { true }

          it_behaves_like 'it creates a DAST on-demand scan pipeline'

          it_behaves_like 'it checks branch permissions before creating a DAST on-demand scan pipeline' do
            let(:branch_name) { params[:branch_name] }
          end

          it_behaves_like 'it delegates scan creation to another service' do
            let(:delegated_params) { hash_including(dast_profile: dast_profile) }
          end
        end

        context 'when the dast_profile does not exist' do
          let(:dast_profile_gid) { Gitlab::GlobalId.build(nil, model_name: 'Dast::Profile', id: 'does_not_exist') }

          it_behaves_like 'an unrecoverable failure'
        end

        context 'when updating fails' do
          it 'returns an error' do
            allow_next_instance_of(::AppSec::Dast::Profiles::UpdateService) do |service|
              allow(service).to receive(:execute).and_return(
                ServiceResponse.error(message: 'Profile failed to update')
              )
            end

            expect(subject[:errors]).to include('Profile failed to update')
          end
        end
      end
    end
  end
end
