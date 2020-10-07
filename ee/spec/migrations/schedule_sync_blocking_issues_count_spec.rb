# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200914185610_schedule_sync_blocking_issues_count')

RSpec.describe ScheduleSyncBlockingIssuesCount do
  let(:issues) { table(:issues) }
  let(:links) { table(:issue_links) }
  let(:migration) { described_class::MIGRATION }

  # Blocking issues
  let!(:issue_1) { issues.create!(description: 'blocking 1', state_id: 1) }
  let!(:issue_2) { issues.create!(description: 'blocking 2', state_id: 1) }
  let!(:issue_3) { issues.create!(description: 'blocking 3', state_id: 2) }
  let!(:issue_4) { issues.create!(description: 'blocking 4', state_id: 1 ) }

  # Blocked issues
  let!(:issue_5) { issues.create!(description: 'blocked 1', state_id: 1) }
  let!(:issue_6) { issues.create!(description: 'blocked 2', state_id: 1) }
  let!(:issue_7) { issues.create!(description: 'blocked 3', state_id: 1) }
  let!(:issue_8) { issues.create!(description: 'blocked 4', state_id: 1) }
  let!(:issue_9) { issues.create!(description: 'blocked 5', state_id: 1) }
  let!(:issue_10) { issues.create!(description: 'blocked 6', state_id: 1) }

  before do
    stub_const("#{described_class.name}::BATCH_SIZE", 2)

    # Issue links
    # -----------
    # issue_1 blocks two issues with link_type BLOCKS
    # issue_2 blocks two issues with link_type IS_BLOCKED_BY
    # issue_3 blocks one issue with link_type IS_BLOCKED_BY but it is closed
    # issue_4 blocks one issue with link_type BLOCKS
    links.create!(link_type: 1, source_id: issue_1.id, target_id: issue_5.id)
    links.create!(link_type: 1, source_id: issue_1.id, target_id: issue_6.id)
    links.create!(link_type: 2, source_id: issue_7.id, target_id: issue_2.id)
    links.create!(link_type: 2, source_id: issue_8.id, target_id: issue_2.id)
    links.create!(link_type: 1, source_id: issue_4.id, target_id: issue_9.id)
    links.create!(link_type: 2, source_id: issue_10.id, target_id: issue_3.id)
  end

  context 'scheduling migrations' do
    before do
      Sidekiq::Worker.clear_all
    end

    it 'correctly schedules issuable sync background migration' do
      Sidekiq::Testing.fake! do
        freeze_time do
          migrate!

          expect(migration).to be_scheduled_delayed_migration(120.seconds, issue_1.id, issue_2.id)
          expect(migration).to be_scheduled_delayed_migration(240.seconds, issue_4.id, issue_4.id)
          expect(BackgroundMigrationWorker.jobs.size).to eq(2)
        end
      end
    end
  end

  context 'running background migration' do
    it 'correctly populates issues blocking_issues_count', :sidekiq_might_not_need_inline do
      migrate!

      expect(issue_1.reload.blocking_issues_count).to eq(2)
      expect(issue_2.reload.blocking_issues_count).to eq(2)
      expect(issue_3.reload.blocking_issues_count).to eq(0)
      expect(issue_4.reload.blocking_issues_count).to eq(1)
    end
  end
end
