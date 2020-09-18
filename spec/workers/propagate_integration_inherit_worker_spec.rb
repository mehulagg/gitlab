# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PropagateIntegrationInheritWorker do
  describe '#perform' do
    let(:integration) { create(:redmine_service, :instance) }
    let!(:integration1) { create(:redmine_service, inherit_from_id: integration.id) }
    let!(:integration2) { create(:bugzilla_service, inherit_from_id: integration.id) }
    let!(:integration3) { create(:redmine_service) }

    it 'calls to BulkCreateIntegrationService' do
      expect(BulkUpdateIntegrationService).to receive(:new)
        .with(integration, match_array(integration1))
        .and_return(double(execute: nil))

      subject.perform(integration.id, integration1.id, integration3.id)
    end
  end
end
