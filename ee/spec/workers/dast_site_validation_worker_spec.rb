# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidationWorker do
  let_it_be(:dast_site_validation) { create(:dast_site_validation) }

  subject do
    described_class.new.perform(dast_site_validation.id)
  end

  describe '#perform' do
    it 'calls DastSiteValidations::ValidateService' do
      double = double(DastSiteValidations::ValidateService, "execute!" => true)
      args = { container: dast_site_validation.project, params: { dast_site_validation: dast_site_validation } }

      expect(double).to receive(:execute!)
      expect(DastSiteValidations::ValidateService).to receive(:new).with(args).and_return(double)

      subject
    end

    context 'when the feature is available' do
      let(:response_body) { dast_site_validation.dast_site_token.token }
      let(:headers) { { 'Content-Type' => 'text/plain; charset=utf-8' } }

      before do
        stub_licensed_features(security_on_demand_scans: true)
        stub_request(:get, dast_site_validation.validation_url).to_return(body: response_body, headers: headers)
      end

      context 'when the request body contains the token' do
        include_examples 'an idempotent worker' do
          subject do
            perform_multiple([dast_site_validation.id], worker: described_class.new)
          end
        end
      end
    end
  end

  describe '.sidekiq_retries_exhausted' do
    it 'calls find with the correct id' do
      job = { 'args' => [dast_site_validation.id], 'jid' => '1' }

      expect(dast_site_validation.class).to receive(:find).with(dast_site_validation.id).and_call_original

      described_class.sidekiq_retries_exhausted_block.call(job)
    end

    it 'marks validation failed' do
      job = { 'args' => [dast_site_validation.id], 'jid' => '1' }

      freeze_time do
        described_class.sidekiq_retries_exhausted_block.call(job)

        aggregate_failures do
          obj = dast_site_validation.reload

          expect(obj.state).to eq('failed')
          expect(obj.validation_failed_at).to eq(Time.now.utc)
        end
      end
    end
  end
end
