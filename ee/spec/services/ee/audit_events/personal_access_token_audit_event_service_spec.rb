# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::AuditEvents::PersonalAccessTokenAuditEventService do
  let(:user) { create(:user) }
  let(:ip_address) { '127.0.0.1' }
  let(:message) { 'Created personal access token' }
  let(:logger) { instance_double(Gitlab::AuditJsonLogger) }
  let(:service) { described_class.new(user, ip_address, message) }

  describe '#security_event' do
    before do
      stub_licensed_features(extended_audit_events: true)
    end

    it 'creates an event and logs to a file with the provided details' do
      expect(service).to receive(:file_logger).and_return(logger)
      expect(logger).to receive(:info).with(author_id: user.id,
        author_name: user.name,
        entity_id: user.id,
        entity_type: 'User',
        action: :custom,
        ip_address: ip_address,
        custom_message: message)

      expect { service.security_event }.to change(AuditEvent, :count).by(1)
      security_event = AuditEvent.last

      expect(security_event.details).to eq(custom_message: message,
        ip_address: ip_address,
        action: :custom)
      expect(security_event.author_id).to eq(user.id)
      expect(security_event.entity_id).to eq(user.id)
      expect(security_event.entity_type).to eq('User')
    end
  end
end
