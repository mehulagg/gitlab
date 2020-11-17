# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::IncidentSlaExceededCheckWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    let_it_be(:incident_sla) { create(:issuable_sla, :exceeded) }
    let_it_be(:other_incident_slas) { create_list(:issuable_sla, 2, :exceeded) }

    let(:label_service_stub) { instance_double(IncidentManagement::ApplyIncidentSlaExceededLabelWorker) }

    it 'calls the apply incident sla label service' do
      expect(IncidentManagement::ApplyIncidentSlaExceededLabelWorker)
        .to receive(:perform_async)
        .exactly(3)
        .times

      perform
    end
  end
end
