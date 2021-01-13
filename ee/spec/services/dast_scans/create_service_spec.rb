# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastScans::CreateService do
  let_it_be(:project) { create(:project) }
  let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }
  let_it_be(:default_params) do
    { name: SecureRandom.hex, description: :description, dast_site_profile: dast_site_profile, dast_scanner_profile: dast_scanner_profile, run_after_create: false }
  end

  let(:params) { default_params }

  subject { described_class.new(container: project, params: params).execute }

  describe 'execute' do
    before do
      project.clear_memoization(:licensed_feature_available)
    end

    context 'when on demand scan feature is disabled' do
      it 'communicates failure' do
        stub_licensed_features(security_on_demand_scans: true)
        stub_feature_flags(dast_saved_scans: false)

        aggregate_failures do
          expect(subject.status).to eq(:error)
          expect(subject.message).to eq('Insufficient permissions')
        end
      end
    end

    context 'when on demand scan licensed feature is not available' do
      it 'communicates failure' do
        stub_licensed_features(security_on_demand_scans: false)
        stub_feature_flags(dast_saved_scans: true)

        aggregate_failures do
          expect(subject.status).to eq(:error)
          expect(subject.message).to eq('Insufficient permissions')
        end
      end
    end

    context 'when the feature is enabled' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
        stub_feature_flags(dast_saved_scans: true)
      end

      it 'communicates success' do
        expect(subject.status).to eq(:success)
      end

      it 'creates a dast_scan' do
        expect { subject }.to change { DastScan.count }.by(1)
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
