# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidations::CreateService do
  let(:project) { dast_site_token.project }
  let(:dast_site_token) { create(:dast_site_token, project: create(:project)) }
  let(:url_path) { SecureRandom.hex }
  let(:params) { { dast_site_token: dast_site_token, url_path: url_path, validation_strategy: :text_file } }

  subject { described_class.new(container: project, params: params).execute }

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

      it 'attempts to validate' do
        aggregate_failures do
          expect(DastSiteValidationWorker).to receive(:perform_async)

          expect { subject }.to change { DastSiteValidation.count }.by(1)
        end
      end

      context 'when the associated dast_site_validation has successfully been validated' do
        it 'returns the existing successful dast_site_validation' do
          dast_site_validation = create(:dast_site_validation, dast_site_token: dast_site_token, state: :passed)

          expect(subject.payload).to eq(dast_site_validation)
        end

        it 'does not attempt to re-validate' do
          create(:dast_site_validation, dast_site_token: dast_site_token, state: :passed)

          aggregate_failures do
            expect(DastSiteValidationWorker).not_to receive(:perform_async)

            expect { subject }.not_to change { DastSiteValidation.count }
          end
        end
      end

      context 'when a param is missing' do
        let(:params) { { dast_site_token: dast_site_token, validation_strategy: :text_file } }

        it 'communicates failure' do
          aggregate_failures do
            expect(subject.status).to eq(:error)
            expect(subject.message).to eq('Key not found: :url_path')
          end
        end
      end

      context 'when the dast_site_token.project and container do not match' do
        let(:project) { create(:project) }

        it 'communicates failure' do
          aggregate_failures do
            expect(subject.status).to eq(:error)
            expect(subject.message).to eq('Insufficient permissions')
          end
        end
      end

      context 'when worker does not return a job id' do
        before do
          allow(DastSiteValidationWorker).to receive(:perform_async).and_return(nil)
        end

        let(:dast_site_validation) do
          DastSiteValidation.find_by!(dast_site_token: dast_site_token, url_path: url_path)
        end

        it 'communicates failure' do
          aggregate_failures do
            expect(subject.status).to eq(:error)
            expect(subject.message).to eq('Validation failed')
          end
        end

        it 'sets dast_site_validation.state to failed' do
          subject

          expect(dast_site_validation.state).to eq('failed')
        end

        it 'logs an error' do
          allow(Gitlab::AppLogger).to receive(:error)

          subject

          expect(Gitlab::AppLogger).to have_received(:error).with(message: 'Unable to validate dast_site_validation', dast_site_validation_id: dast_site_validation.id)
        end
      end
    end
  end
end
