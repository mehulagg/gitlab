# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe ScheduleSetDefaultIterationCadences do
  let(:namespaces) { table(:namespaces) }
  let(:iterations) { table(:sprints) }

  let(:group_1) { namespaces.create!(name: 'test_1', path: 'test_1') }
  let(:group_2) { namespaces.create!(name: 'test_2', path: 'test_2') }
  let(:group_3) { namespaces.create!(name: 'test_3', path: 'test_3') }

  let!(:iteration_1) { iterations.create!(iid: 1, title: 'iteration 1', group_id: group_1.id) }
  let!(:iteration_2) { iterations.create!(iid: 1, title: 'iteration 2', group_id: group_3.id) }

  around do |example|
    freeze_time { Sidekiq::Testing.fake! { example.run } }
  end

  it 'schedules the background jobs', :aggregate_failures do
    stub_const("#{described_class.name}::BATCH_SIZE", 1)

    migrate!

    expect(BackgroundMigrationWorker.jobs.size).to be(2)
    expect(described_class::MIGRATION_CLASS).to be_scheduled_delayed_migration(2.minutes, group_1.id)
    expect(described_class::MIGRATION_CLASS).to be_scheduled_delayed_migration(4.minutes, group_3.id)
  end
end
