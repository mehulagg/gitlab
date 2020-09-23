# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PropagateIntegrationGroupWorker do
  describe '#perform' do
    let!(:group1) { create(:group) }
    let!(:group2) { create(:group) }
    let!(:integration) { create(:redmine_service, :instance) }

    before do
      allow(BulkCreateIntegrationService).to receive(:new)
        .with(integration, match_array([group1, group2]), 'group')
        .and_return(double(execute: nil))
    end

    it_behaves_like 'an idempotent worker' do
      let(:job_args) { [integration.id, group1.id, group2.id] }

      it 'calls to BulkCreateIntegrationService' do
        expect(BulkCreateIntegrationService).to receive(:new)
          .with(integration, match_array([group1, group2]), 'group')
          .and_return(double(execute: nil))

        subject
      end
    end

    context 'with an invalid integration id' do
      it 'returns without failure' do
        expect(BulkCreateIntegrationService).not_to receive(:new)

        subject.perform(0, group1.id, group2.id)
      end
    end
  end
end
