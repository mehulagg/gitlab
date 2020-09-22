# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PropagateIntegrationGroupWorker do
  describe '#perform' do
    let!(:group1) { create(:group) }
    let!(:group2) { create(:group) }
    let!(:integration) { create(:redmine_service, :instance) }

    it 'calls to BulkCreateIntegrationService' do
      expect(BulkCreateIntegrationService).to receive(:new)
        .with(integration, match_array([group1, group2]), 'group')
        .and_return(double(execute: nil))

      subject.perform(integration.id, group1.id, group2.id)
    end
  end
end
