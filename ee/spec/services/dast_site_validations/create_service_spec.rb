# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidations::CreateService do
  let(:project) { create(:project) }
  let(:target_url) { generate(:url) }

  subject do
    described_class.new(
      container: project,
      params: { target_url: target_url }
    ).execute
  end

  describe 'execute' do
    context 'when on demand scan feature is disabled' do
      it 'communicates failure' do
        stub_licensed_features(security_on_demand_scans: true)
        stub_feature_flags(security_on_demand_scans_site_validation: false)

        aggregate_failures do
          expect(subject.status).to eq(:error)
          expect(subject.message).to eq('Insufficient permissions')
        end
      end
    end

    context 'when on demand scan licensed feature is not available' do
      it 'communicates failure' do
        stub_licensed_features(security_on_demand_scans: false)
        stub_feature_flags(security_on_demand_scans_site_validation: true)

        aggregate_failures do
          expect(subject.status).to eq(:error)
          expect(subject.message).to eq('Insufficient permissions')
        end
      end
    end

    context 'when the feature is enabled' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
        stub_feature_flags(security_on_demand_scans_site_validation: true)
      end

      it 'communicates success' do
        expect(subject.status).to eq(:success)
      end

      it 'contains a dast_site_validation' do
        expect(subject.payload[:dast_site_token]).to be_a(DastSiteToken)
      end

      it 'contains a status' do
        expect(subject.payload[:status]).to eq('PENDING_VALIDATION')
      end

      context 'when a downstream exception is thrown because an invalid target_url is given' do
        it 'does not create a dast_site_validation' do
          allow(DastSiteValidation).to receive(:get_normalized_url_base).and_raise(RuntimeError)

          expect { subject }.to raise_error(RuntimeError).and not_change { DastSiteValidation.count }
        end
      end
    end
  end
end
