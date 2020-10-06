# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidations::ValidateService do
  let(:dast_site_validation) { create(:dast_site_validation) }

  subject do
    described_class.new(
      container: dast_site_validation.project,
      params: { dast_site_validation: dast_site_validation }
    ).execute!
  end

  describe 'execute!' do
    context 'when on demand scan feature is disabled' do
      it 'communicates failure' do
        stub_licensed_features(security_on_demand_scans: true)
        stub_feature_flags(security_on_demand_scans_site_validation: false)

        expect { subject }.to raise_error(DastSiteValidations::ValidateService::PermissionsError)
      end
    end

    context 'when on demand scan licensed feature is not available' do
      it 'communicates failure' do
        stub_licensed_features(security_on_demand_scans: false)
        stub_feature_flags(security_on_demand_scans_site_validation: true)

        expect { subject }.to raise_error(DastSiteValidations::ValidateService::PermissionsError)
      end
    end

    context 'when the feature is enabled' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
        stub_feature_flags(security_on_demand_scans_site_validation: true)
        stub_request(:get, dast_site_validation.validation_url).to_return(body: response_body)
      end

      let(:response_body) do
        dast_site_validation.dast_site_token.token
      end

      it 'validates the url before making an http request' do
        uri = double('uri')

        aggregate_failures do
          expect(Gitlab::UrlBlocker).to receive(:validate!).and_return([uri, nil])
          expect(Gitlab::HTTP).to receive(:get).with(uri).and_return(double('response', body: dast_site_validation.dast_site_token.token))
        end

        subject
      end

      context 'when the request body contains the token' do
        it 'calls dast_site_validation#start' do
          expect(dast_site_validation).to receive(:start)

          subject
        end

        it 'calls dast_site_validation#pass' do
          expect(dast_site_validation).to receive(:pass)

          subject
        end

        it 'marks the validation successful' do
          subject

          expect(dast_site_validation.reload.state).to eq('passed')
        end

        context 'when validation has already started' do
          let(:dast_site_validation) { create(:dast_site_validation, state: :inprogress) }

          it 'does not call dast_site_validation#pass' do
            expect(dast_site_validation).not_to receive(:start)

            subject
          end
        end

        context 'when validation is already complete' do
          let(:dast_site_validation) { create(:dast_site_validation, state: :passed) }

          it 'does not re-validate' do
            expect(Gitlab::HTTP).not_to receive(:get)

            subject
          end
        end
      end

      context 'when the request body does not contain the token' do
        let(:response_body) do
          SecureRandom.hex
        end

        it 'raises an exception' do
          expect { subject }.to raise_error(DastSiteValidations::ValidateService::TokenNotFound)
        end
      end

      context 'when validation has already been attempted' do
        let_it_be(:dast_site_validation) { create(:dast_site_validation, state: :failed) }

        it 'marks the validation as a retry' do
          freeze_time do
            subject

            expect(dast_site_validation.reload.validation_last_retried_at).to eq(Time.now.utc)
          end
        end
      end
    end
  end
end
