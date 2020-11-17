# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe ScheduleFixOrphanPromotedIssues do
  let(:projects) { table(:projects) }
  let(:notes) { table(:notes) }
  let(:project1) { projects.create!(namespace_id: 99) }
  let!(:promote_orphan_1_note) { notes.create!(project_id: project1.id, noteable_id: 1, noteable_type: "Issue", note: "promoted to epic &14532", system: true) }
  let!(:promote_orphan_2_note) { notes.create!(project_id: project1.id, noteable_id: 2, noteable_type: "Issue", note: "promoted to epic &209", system: true) }
  let!(:promote_orphan_3_note) { notes.create!(project_id: project1.id, noteable_id: 4, noteable_type: "Issue", note: "promoted to epic &12", system: true) }

  it 'correctly schedules background migrations' do
    stub_const("#{described_class.name}::BATCH_SIZE", 2)

    Sidekiq::Testing.fake! do
      freeze_time do
        migrate!

        expect(described_class::BACKGROUND_MIGRATION).to be_scheduled_migration(promote_orphan_1_note.id)
        expect(described_class::BACKGROUND_MIGRATION).to be_scheduled_migration(promote_orphan_2_note.id)
        expect(described_class::BACKGROUND_MIGRATION).to be_scheduled_migration(promote_orphan_3_note.id)
        expect(BackgroundMigrationWorker.jobs.size).to eq(3)
      end
    end
  end
end
