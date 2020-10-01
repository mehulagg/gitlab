# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PropagateIntegrationProjectWorker do
  describe '#perform' do
    let_it_be(:integration) { create(:redmine_service, :instance) }
    let(:batch) { double }

    before do
      allow(Project).to receive(:without_integration).and_return(batch)

      allow(BulkCreateIntegrationService).to receive(:new)
        .with(integration, batch, 'project')
        .and_return(double(execute: nil))
    end

    it_behaves_like 'an idempotent worker' do
      let(:job_args) { [integration.id, 1, 100] }

      it 'calls to BulkCreateIntegrationService' do
        expect(Project).to receive(:without_integration).and_return(batch)

        expect(BulkCreateIntegrationService).to receive(:new)
          .with(integration, batch, 'project')
          .and_return(double(execute: nil))

        subject
      end

      context 'with a group integration' do
        let_it_be(:group) { create(:group) }
        let_it_be(:integration) { create(:redmine_service, group: group, project: nil) }
        let(:job_args) { [integration.id, 1, 100] }

        before do
          allow(Project).to receive(:belonging_to_group_without_integration).and_return(batch)
        end

        it 'calls to BulkCreateIntegrationService' do
          expect(Project).to receive(:belonging_to_group_without_integration).and_return(batch)

          expect(BulkCreateIntegrationService).to receive(:new)
            .with(integration, batch, 'project')
            .and_return(double(execute: nil))

          subject
        end
      end
    end

    context 'with an invalid integration id' do
      it 'returns without failure' do
        expect(BulkCreateIntegrationService).not_to receive(:new)

        subject.perform(0, 1, 100)
      end
    end
  end
end
