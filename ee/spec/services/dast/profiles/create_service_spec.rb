# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::Profiles::CreateService do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:developer) { create(:user, developer_projects: [project] ) }
  let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

  let_it_be(:default_params) do
    {
      name: SecureRandom.hex,
      description: :description,
      branch_name: 'orphaned-branch',
      dast_site_profile: dast_site_profile,
      dast_scanner_profile: dast_scanner_profile,
      run_after_create: false
    }
  end

  let(:params) { default_params }

  subject { described_class.new(container: project, current_user: developer, params: params).execute }

  describe 'execute' do
    context 'when on demand scan licensed feature is not available' do
      it 'communicates failure' do
        stub_licensed_features(security_on_demand_scans: false)

        aggregate_failures do
          expect(subject.status).to eq(:error)
          expect(subject.message).to eq('Insufficient permissions')
        end
      end
    end

    context 'when the feature is enabled' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
      end

      it 'communicates success' do
        expect(subject.status).to eq(:success)
      end

      it 'creates a dast_profile' do
        expect { subject }.to change { Dast::Profile.count }.by(1)
      end

      context 'when param run_after_create: true' do
        let(:params) { default_params.merge(run_after_create: true) }

        it_behaves_like 'it delegates scan creation to another service' do
          let(:delegated_params) { hash_including(dast_profile: instance_of(Dast::Profile)) }
        end

        it 'creates a ci_pipeline' do
          expect { subject }.to change { Ci::Pipeline.count }.by(1)
        end
      end

      context 'when a param is missing' do
        let(:params) { default_params.except(:run_after_create) }

        it 'communicates failure' do
          aggregate_failures do
            expect(subject.status).to eq(:error)
            expect(subject.message).to eq('Key not found: :run_after_create')
          end
        end
      end
    end
  end
end
