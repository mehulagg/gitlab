# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20201109114603_schedule_remove_inaccessible_epic_todos')

RSpec.describe ScheduleRemoveInaccessibleEpicTodos do
  let(:group) { table(:namespaces).create!(name: 'gitlab', path: 'gitlab-org') }
  let(:user) { table(:users).create!(email: 'user@example.com', projects_limit: 10) }
  let!(:epic1) { table(:epics).create!(iid: 1, title: 'foo', title_html: 'foo', group_id: group.id, author_id: user.id, confidential: true) }
  let!(:epic2) { table(:epics).create!(iid: 2, title: 'foo', title_html: 'foo', group_id: group.id, author_id: user.id) }
  let!(:epic3) { table(:epics).create!(iid: 3, title: 'foo', title_html: 'foo', group_id: group.id, author_id: user.id, confidential: true) }

  before do
    stub_const("#{described_class.name}::BATCH_SIZE", 1)
  end

  it 'schedules jobs for confidental epic todos' do
    Sidekiq::Testing.fake! do
      freeze_time do
        migrate!

        expect(described_class::MIGRATION).to be_scheduled_delayed_migration(
          2.minutes, epic1.id, epic1.id)
        expect(described_class::MIGRATION).to be_scheduled_delayed_migration(
          4.minutes, epic3.id, epic3.id)
        expect(BackgroundMigrationWorker.jobs.size).to eq(2)
      end
    end
  end
end
