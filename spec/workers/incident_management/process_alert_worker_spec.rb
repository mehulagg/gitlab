# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::ProcessAlertWorker do
  let_it_be(:project) { create(:project) }
  let_it_be(:settings) { create(:project_incident_management_setting, project: project, create_issue: true) }

  describe '#perform' do
    let_it_be(:started_at) { Time.now.rfc3339 }
    let_it_be(:payload) { { 'title' => 'title', 'start_time' => started_at } }
    let_it_be(:alert) { create(:alert_management_alert, project: project, payload: payload, started_at: started_at) }

    let(:created_issue) { Issue.last! }

    subject { described_class.new.perform(nil, nil, alert.id) }

    it 'does nothing' do
      expect(AlertManagement::CreateAlertIssueService).not_to receive(:new)

      expect { subject }.not_to change { Issue.count }
    end
  end
end
