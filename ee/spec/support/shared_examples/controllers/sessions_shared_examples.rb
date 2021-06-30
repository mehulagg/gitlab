# frozen_string_literal: true

RSpec.shared_examples 'an auditable failed authentication' do
  it 'log an audit event', :aggregate_failures do
    audit_event_service = instance_spy(AuditEventService)
    allow(AuditEventService).to receive(:new).and_return(audit_event_service)

    operation

    expect(AuditEventService).to have_received(:new).with(user, user, with: method)
    expect(audit_event_service).to have_received(:for_failed_login)
    expect(audit_event_service).to have_received(:unauth_security_event)
  end
end
