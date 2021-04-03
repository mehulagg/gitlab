# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::Profiles::UpdateService do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }
  let_it_be(:dast_profile, reload: true) { create(:dast_profile, project: project, branch_name: 'orphaned-branch') }
  let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

  let(:default_params) do
    {
      name: SecureRandom.hex,
      description: SecureRandom.hex,
      branch_name: 'orphaned-branch',
      dast_profile: dast_profile,
      dast_site_profile_id: dast_site_profile.id,
      dast_scanner_profile_id: dast_scanner_profile.id
    }
  end

  let(:params) { default_params }

  subject do
    described_class.new(
      container: project,
      current_user: user,
      params: params
    ).execute
  end

  describe 'execute', :clean_gitlab_redis_shared_state do
    context 'when on demand scan licensed feature is not available' do
      it 'communicates failure' do
        stub_licensed_features(security_on_demand_scans: false)

        aggregate_failures do
          expect(subject.status).to eq(:error)
          expect(subject.message).to eq('You are not authorized to update this profile')
        end
      end
    end

    context 'when the feature is enabled' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
      end

      context 'when the user cannot run a DAST scan' do
        it 'communicates failure' do
          aggregate_failures do
            expect(subject.status).to eq(:error)
            expect(subject.message).to eq('You are not authorized to update this profile')
          end
        end
      end

      context 'when the user can run a DAST scan' do
        before do
          project.add_developer(user)
        end

        it 'communicates success' do
          expect(subject.status).to eq(:success)
        end

        it 'updates the dast_profile' do
          updated_dast_profile = subject.payload[:dast_profile].reload

          aggregate_failures do
            expect(updated_dast_profile.dast_site_profile.id).to eq(params[:dast_site_profile_id])
            expect(updated_dast_profile.dast_scanner_profile.id).to eq(params[:dast_scanner_profile_id])
            expect(updated_dast_profile.name).to eq(params[:name])
            expect(updated_dast_profile.description).to eq(params[:description])
          end
        end

        context 'when param run_after_update: true' do
          let(:params) { default_params.merge(run_after_update: true) }

          it_behaves_like 'it delegates scan creation to another service' do
            let(:delegated_params) { hash_including(dast_profile: dast_profile) }
          end

          it 'creates a ci_pipeline' do
            expect { subject }.to change { Ci::Pipeline.count }.by(1)
          end
        end

        context 'when dast_profile param is missing' do
          let(:params) { {} }

          it 'communicates failure' do
            aggregate_failures do
              expect(subject.status).to eq(:error)
              expect(subject.message).to eq('Profile parameter missing')
            end
          end
        end
      end
    end
  end
end
