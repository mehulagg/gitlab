# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20210514063252_schedule_cleanup_orphaned_lfs_objects_projects.rb')

RSpec.describe ScheduleCleanupOrphanedLfsObjectsProjects, :sidekiq, schema: 20210511165250 do
  let(:lfs_objects_projects) { table(:lfs_objects_projects) }

  describe '#up' do
    before do
      stub_const("#{described_class}::BATCH_SIZE", 2)

      ActiveRecord::Base.connection.disable_referential_integrity do
        lfs_objects_projects.create!(id: 1, project_id: 1, lfs_object_id: 1)
        lfs_objects_projects.create!(id: 2, project_id: 1, lfs_object_id: 2)
        lfs_objects_projects.create!(id: 3, project_id: 2, lfs_object_id: 1)
        lfs_objects_projects.create!(id: 4, project_id: 2, lfs_object_id: 2)
        lfs_objects_projects.create!(id: 5, project_id: 3, lfs_object_id: 3)
      end
    end

    it 'schedules CleanupOrphanedLfsObjectsProjects background jobs' do
      Sidekiq::Testing.fake! do
        freeze_time do
          migrate!

          expect(described_class::MIGRATION).to be_scheduled_delayed_migration(2.minutes, 1, 2)
          expect(described_class::MIGRATION).to be_scheduled_delayed_migration(4.minutes, 3, 4)
          expect(described_class::MIGRATION).to be_scheduled_delayed_migration(6.minutes, 5, 5)

          expect(BackgroundMigrationWorker.jobs.size).to eq(3)
        end
      end
    end
  end
end
