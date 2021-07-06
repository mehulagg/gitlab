# frozen_string_literal: true

require 'spec_helper'
require_migration!('finalize_traversal_ids_background_migrations')

RSpec.describe FinalizeTraversalIdsBackgroundMigrations, :redis do
  shared_examples 'Sidekiq enqueued jobs are finalized' do
    before do
      # Jobs enqueued in Sidekiq.
      Sidekiq::Testing.disable! do
        BackgroundMigrationWorker.perform_in(10, job_class, [1, 4, 100])
        BackgroundMigrationWorker.perform_in(20, job_class, [5, 9, 100])
      end

      # Jobs tracked in the database.
      table(:background_migration_jobs).create!(
        class_name: job_class,
        arguments: [1, 4, 100],
        status: Gitlab::Database::BackgroundMigrationJob.statuses['pending']
      )
      table(:background_migration_jobs).create!(
        class_name: job_class,
        arguments: [5, 9, 100],
        status: Gitlab::Database::BackgroundMigrationJob.statuses['succeeded']
      )

      migrate!
    end

    def jobs_with_status(status)
      table(:background_migration_jobs)
        .where(status: Gitlab::Database::BackgroundMigrationJob.statuses[status])
    end

    it 'empties the sidekiq queue' do
      expect(Sidekiq::ScheduledSet.new.size).to eq(0)
    end

    it 'steals sidekiq jobs' do
      expect(jobs_with_status('pending')).to be_empty
    end

    it 'removes successful jobs' do
      expect(jobs_with_status('succeeded')).to be_empty
    end
  end

  context 'BackfillNamespaceTraversalIdsRoots background migration' do
    it_behaves_like 'Sidekiq enqueued jobs are finalized' do
      let(:job_class) { 'BackfillNamespaceTraversalIdsRoots' }
    end
  end
  
  context 'BackfillNamespaceTraversalIdsChildren background migration' do
    let(:job_class) { 'BackfillNamespaceTraversalIdsChildren' }

    it_behaves_like 'Sidekiq enqueued jobs are finalized'
  end
end
