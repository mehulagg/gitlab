# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidations::RevokeService do
  let_it_be(:dast_site_validation) { create(:dast_site_validation, state: :passed) }
  let_it_be(:project) { dast_site_validation.project }

  let(:params) { { url_base: dast_site_validation.url_base } }

  subject { described_class.new(container: project, params: params).execute }

  describe 'execute', :clean_gitlab_redis_shared_state do
    before do
      project.clear_memoization(:licensed_feature_available)
    end

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

      it 'deletes dast_site_validations where state=passed' do
        expect { subject }.to change { DastSiteValidation.count }.from(1).to(0)
      end

      context 'when a param is missing' do
        let(:params) { {} }

        it 'communicates failure' do
          aggregate_failures do
            expect(subject.status).to eq(:error)
            expect(subject.message).to eq('Key not found: :url_base')
          end
        end
      end
    end
  end
end
