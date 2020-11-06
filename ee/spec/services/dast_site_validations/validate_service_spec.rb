# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidations::ValidateService do
  let(:dast_site_validation) { create(:dast_site_validation) }
  let(:token) { dast_site_validation.dast_site_token.token }

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
        stub_request(:get, dast_site_validation.validation_url).to_return(body: token)
      end

      it 'validates the url before making an http request' do
        uri = URI(dast_site_validation.validation_url)
        opt = hash_including(allow_local_network: false, allow_localhost: false, dns_rebind_protection: true)

        aggregate_failures do
          expect(Gitlab::UrlBlocker).to receive(:validate!).with(uri, opt).and_call_original
          expect(Gitlab::HTTP).to receive(:get).with(dast_site_validation.validation_url).and_call_original
        end

        subject
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

      shared_examples 'a validation' do
        context 'when the token is found' do
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
            before do
              dast_site_validation.update_column(:state, :inprogress)
            end

            it 'does not call dast_site_validation#pass' do
              expect(dast_site_validation).not_to receive(:start)

              subject
            end
          end

          context 'when validation is already complete' do
            before do
              dast_site_validation.update_column(:state, :passed)
            end

            it 'does not re-validate' do
              expect(Gitlab::HTTP).not_to receive(:get)

              subject
            end
          end
        end

        context 'when the token is not found' do
          let(:token) do
            SecureRandom.hex
          end

          it 'raises an exception' do
            expect { subject }.to raise_error(DastSiteValidations::ValidateService::TokenNotFound)
          end
        end
      end

      context 'when validation_strategy=text_file' do
        let(:dast_site_validation) { create(:dast_site_validation, validation_strategy: :text_file) }

        before do
          stub_request(:get, dast_site_validation.validation_url).to_return(body: token)
        end

        it_behaves_like 'a validation'
      end

      context 'when validation_strategy=header' do
        let(:dast_site_validation) { create(:dast_site_validation, validation_strategy: :header) }

        before do
          headers = { DastSiteValidation::HEADER => token }

          stub_request(:get, dast_site_validation.validation_url).to_return(headers: headers)
        end

        it_behaves_like 'a validation'
      end
    end
  end
end
