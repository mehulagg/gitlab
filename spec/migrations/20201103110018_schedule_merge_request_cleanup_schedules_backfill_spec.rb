# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20201103110018_schedule_merge_request_cleanup_schedules_backfill.rb')

RSpec.describe ScheduleMergeRequestCleanupSchedulesBackfill, :sidekiq, schema: 20201023114628 do
  let(:merge_requests) { table(:merge_requests) }
  let(:cleanup_schedules) { table(:merge_request_cleanup_schedules) }

  let(:namespace) { table(:namespaces).create!(name: 'name', path: 'path') }
  let(:project) { table(:projects).create!(namespace_id: namespace.id) }

  describe '#up' do
    let!(:open_mr) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master') }

    let!(:closed_mr_1) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master', state_id: '2') }
    let!(:closed_mr_2) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master', state_id: '2') }
    let!(:closed_mr_3) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master', state_id: '2') }
    let!(:closed_mr_4) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master', state_id: '2') }
    let!(:closed_mr_5) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master', state_id: '2') }

    let!(:merged_mr_1) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master', state_id: '3') }
    let!(:merged_mr_2) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master', state_id: '3') }
    let!(:merged_mr_3) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master', state_id: '3') }
    let!(:merged_mr_4) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master', state_id: '3') }
    let!(:merged_mr_5) { merge_requests.create!(target_project_id: project.id, source_branch: 'master', target_branch: 'master', state_id: '3') }

    before do
      stub_const("#{described_class}::BATCH_SIZE", 2)

      cleanup_schedules.create!(merge_request_id: closed_mr_2.id, scheduled_at: Time.current)
      cleanup_schedules.create!(merge_request_id: merged_mr_2.id, scheduled_at: Time.current)
    end

    it 'schdules BackfillClosedMergeRequestCleanupSchedules and BackfillMergedMergeRequestCleanupSchedules background jobs' do
      Sidekiq::Testing.fake! do
        freeze_time do
          migrate!

          aggregate_failures do
            expect(described_class::CLOSED_MIGRATION)
              .to be_scheduled_delayed_migration(2.minutes, closed_mr_1.id, closed_mr_3.id)
            expect(described_class::CLOSED_MIGRATION)
              .to be_scheduled_delayed_migration(4.minutes, closed_mr_4.id, closed_mr_5.id)
            expect(described_class::MERGED_MIGRATION)
              .to be_scheduled_delayed_migration(2.minutes, merged_mr_1.id, merged_mr_3.id)
            expect(described_class::MERGED_MIGRATION)
              .to be_scheduled_delayed_migration(4.minutes, merged_mr_4.id, merged_mr_5.id)
            expect(BackgroundMigrationWorker.jobs.size).to eq(4)
          end
        end
      end
    end
  end
end
