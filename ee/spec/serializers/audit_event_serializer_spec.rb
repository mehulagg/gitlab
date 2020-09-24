# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEventSerializer do
  describe '.represent' do
    it 'returns an empty array when there are no audit events' do
      result = described_class.new.represent([])

      expect(result).to eq([])
    end

    it 'includes audit event attributes' do
      audit_event = create(:audit_event)
      audit_events = [audit_event]

      result = described_class.new.represent(audit_events)

      expect(result.first.keys.sort).to eq([:action, :author, :date, :id, :ip_address, :object, :target])
    end
  end
end
