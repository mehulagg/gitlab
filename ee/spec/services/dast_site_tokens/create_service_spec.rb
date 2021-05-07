# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteTokens::CreateService do
  let(:project) { create(:project) }
  let(:target_url) { generate(:url) }

  subject do
    described_class.new(
      container: project,
      params: { target_url: target_url }
    ).execute
  end

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

    context 'when the feature is available' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
      end

      it 'communicates success' do
        expect(subject.status).to eq(:success)
      end

      it 'contains a dast_site_validation' do
        expect(subject.payload[:dast_site_token]).to be_a(DastSiteToken)
      end

      it 'contains a status' do
        expect(subject.payload[:status]).to eq('pending')
      end

      context 'when an invalid target_url is supplied' do
        let(:target_url) { 'http://bogus:broken' }

        it 'communicates failure' do
          aggregate_failures do
            expect(subject.status).to eq(:error)
            expect(subject.message).to eq('Invalid target_url')
          end
        end

        it 'does not create a dast_site_validation' do
          expect { subject }.to not_change { DastSiteValidation.count }
        end
      end
    end
  end
end
