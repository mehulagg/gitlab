# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PropagateIntegrationInheritWorker do
  describe '#perform' do
    let(:integration) { create(:redmine_service, :instance) }
    let!(:integration1) { create(:redmine_service, inherit_from_id: integration.id) }
    let!(:integration2) { create(:bugzilla_service, inherit_from_id: integration.id) }
    let!(:integration3) { create(:redmine_service) }

    before do
      allow(BulkUpdateIntegrationService).to receive(:new)
        .with(integration, match_array(integration1))
        .and_return(double(execute: nil))
    end

    it_behaves_like 'an idempotent worker' do
      let(:job_args) { [integration.id, integration1.id, integration3.id] }

      it 'calls to BulkCreateIntegrationService' do
        expect(BulkUpdateIntegrationService).to receive(:new)
          .with(integration, match_array(integration1))
          .and_return(double(execute: nil))

        subject
      end
    end

    context 'with an invalid integration id' do
      it 'returns without failure' do
        expect(BulkUpdateIntegrationService).not_to receive(:new)

        subject.perform(0, integration1.id, integration3.id)
      end
    end
  end
end
