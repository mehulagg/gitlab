# frozen_string_literal: true

RSpec.shared_examples 'creates and processes an escalation' do
  specify do
    escalation = double(IncidentManagement::AlertEscalation)
    process_service = instance_spy(IncidentManagement::Escalations::ProcessService)

    expect(IncidentManagement::AlertEscalation).to receive(:create!)
      .with(alert: a_kind_of(AlertManagement::Alert), policy: a_kind_of(IncidentManagement::EscalationPolicy))
      .and_return(escalation)

    expect(IncidentManagement::Escalations::ProcessService).to receive(:new)
      .with(escalation)
      .and_return(process_service)

    subject

    expect(process_service).to have_received(:execute)
  end
end
