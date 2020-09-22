# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PropagateIntegrationProjectWorker do
  describe '#perform' do
    let!(:project1) { create(:project) }
    let!(:project2) { create(:project) }
    let!(:integration) { create(:redmine_service, :instance) }

    it 'calls to BulkCreateIntegrationService' do
      expect(BulkCreateIntegrationService).to receive(:new)
        .with(integration, match_array([project1, project2]), 'project')
        .and_return(double(execute: nil))

      subject.perform(integration.id, project1.id, project2.id)
    end
  end
end
