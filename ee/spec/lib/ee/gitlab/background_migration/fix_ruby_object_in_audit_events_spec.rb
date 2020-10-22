# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::FixRubyObjectInAuditEvents, :migration, schema: 20200518114540 do
  let(:audit_events) { table(:audit_events) }

  it 'cleans up ruby/object in details field', :aggregate_failures do
    tainted_audit_event = audit_events.create!(
      author_id: -1,
      entity_id: 1,
      entity_type: 'User',
      details: "---\n:failed_login: STANDARD\n:author_name: hacker\n" \
               ":target_details: !ruby/object:Gitlab::Audit::UnauthenticatedAuthor\n  id: -1\n  name: hacker\n" \
               ":ip_address: \n:entity_path: \n"
    )

    clean_audit_event = audit_events.create!(
      author_id: 1,
      entity_id: 1,
      entity_type: 'User',
      details: "---\n:failed_login: STANDARD\n:author_name: homer\n" \
               ":target_details: homer\n" \
               ":ip_address: \n:entity_path: \n"
    )

    described_class.new.perform(tainted_audit_event.id, clean_audit_event.id)

    expect(tainted_audit_event.reload.details).to eq(
      "---\n:failed_login: STANDARD\n:author_name: hacker\n" \
      ":target_details: hacker\n" \
      ":ip_address: \n:entity_path: \n"
    )

    expect(clean_audit_event.reload.details).to eq(
      "---\n:failed_login: STANDARD\n:author_name: homer\n" \
      ":target_details: homer\n" \
      ":ip_address: \n:entity_path: \n"
    )
  end
end
