# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe ScheduleFixRubyObjectInAuditEvents do
  let(:audit_events) { table(:audit_events) }

  it 'schedules background migrations' do
    stub_const("#{described_class.name}::BATCH_SIZE", 1)

    audit_events.create!(
      author_id: -1,
      entity_id: 1,
      entity_type: 'User',
      details: "---\n:failed_login: STANDARD\n:author_name: hacker\n" \
               ":target_details: !ruby/object:Gitlab::Audit::UnauthenticatedAuthor\n  id: -1\n  name: hacker\n" \
               ":ip_address: \n:entity_path: \n"
    )

    audit_events.create!(
      author_id: 1,
      entity_id: 1,
      entity_type: 'User',
      details: "---\n:failed_login: STANDARD\n:author_name: homer\n" \
               ":target_details: homer\n" \
               ":ip_address: \n:entity_path: \n"
    )

    Sidekiq::Testing.fake! do
      migrate!

      expect(BackgroundMigrationWorker.jobs.size).to eq(1)
    end
  end
end
