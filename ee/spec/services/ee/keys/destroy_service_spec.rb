# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Keys::DestroyService do
  let(:user) { create(:user) }

  subject { described_class.new(user) }

  it 'does not destroy LDAP key' do
    key = create(:ldap_key)

    expect { subject.execute(key) }.not_to change(Key, :count)
    expect(key).not_to be_destroyed
  end

  it 'creates an audit event', :aggregate_failures do
    key = create(:personal_key)

    expect { subject.execute(key) }.to change(AuditEvent, :count).by(1)

    audit_event = AuditEvent.last

    expect(audit_event.author).to eq(user)
    expect(audit_event.entity_id).to eq(key.user.id)
    expect(audit_event.target_id).to eq(key.id)
    expect(audit_event.target_type).to eq(key.class.name)
    expect(audit_event.target_details).to eq(key.title)
    expect(audit_event.details[:custom_message]).to eq('Removed SSH key')
  end
end
