# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::Migrations::BackgroundMigrationHelpers do
  let(:model) do
    ActiveRecord::Migration.new.extend(described_class)
  end

  describe '#bulk_queue_background_migration_jobs_by_range' do
    context 'when the model has an ID column' do
      let!(:id1) { create(:user).id }
      let!(:id2) { create(:user).id }
      let!(:id3) { create(:user).id }

      before do
        User.class_eval do
          include EachBatch
        end
      end

      context 'with enough rows to bulk queue jobs more than once' do
        before do
          stub_const('Gitlab::Database::Migrations::BackgroundMigrationHelpers::BACKGROUND_MIGRATION_JOB_BUFFER_SIZE', 1)
        end

        it 'queues jobs correctly' do
          Sidekiq::Testing.fake! do
            model.bulk_queue_background_migration_jobs_by_range(User, 'FooJob', batch_size: 2)

            expect(BackgroundMigrationWorker.jobs[0]['args']).to eq(['FooJob', [id1, id2]])
            expect(BackgroundMigrationWorker.jobs[1]['args']).to eq(['FooJob', [id3, id3]])
          end
        end

        it 'queues jobs in groups of buffer size 1' do
          expect(BackgroundMigrationWorker).to receive(:bulk_perform_async).with([['FooJob', [id1, id2]]])
          expect(BackgroundMigrationWorker).to receive(:bulk_perform_async).with([['FooJob', [id3, id3]]])

          model.bulk_queue_background_migration_jobs_by_range(User, 'FooJob', batch_size: 2)
        end
      end

      context 'with not enough rows to bulk queue jobs more than once' do
        it 'queues jobs correctly' do
          Sidekiq::Testing.fake! do
            model.bulk_queue_background_migration_jobs_by_range(User, 'FooJob', batch_size: 2)

            expect(BackgroundMigrationWorker.jobs[0]['args']).to eq(['FooJob', [id1, id2]])
            expect(BackgroundMigrationWorker.jobs[1]['args']).to eq(['FooJob', [id3, id3]])
          end
        end

        it 'queues jobs in bulk all at once (big buffer size)' do
          expect(BackgroundMigrationWorker).to receive(:bulk_perform_async).with([['FooJob', [id1, id2]],
                                                                                  ['FooJob', [id3, id3]]])

          model.bulk_queue_background_migration_jobs_by_range(User, 'FooJob', batch_size: 2)
        end
      end

      context 'without specifying batch_size' do
        it 'queues jobs correctly' do
          Sidekiq::Testing.fake! do
            model.bulk_queue_background_migration_jobs_by_range(User, 'FooJob')

            expect(BackgroundMigrationWorker.jobs[0]['args']).to eq(['FooJob', [id1, id3]])
          end
        end
      end
    end

    context "when the model doesn't have an ID column" do
      it 'raises error (for now)' do
        expect do
          model.bulk_queue_background_migration_jobs_by_range(ProjectAuthorization, 'FooJob')
        end.to raise_error(StandardError, /does not have an ID/)
      end
    end
  end

  describe '#queue_background_migration_jobs_by_range_at_intervals' do
    context 'when the model has an ID column' do
      let!(:id1) { create(:user).id }
      let!(:id2) { create(:user).id }
      let!(:id3) { create(:user).id }

      around do |example|
        freeze_time { example.run }
      end

      before do
        User.class_eval do
          include EachBatch
        end
      end

      it 'returns the final expected delay' do
        Sidekiq::Testing.fake! do
          final_delay = model.queue_background_migration_jobs_by_range_at_intervals(User, 'FooJob', 10.minutes, batch_size: 2)

          expect(final_delay.to_f).to eq(20.minutes.to_f)
        end
      end

      it 'returns zero when nothing gets queued' do
        Sidekiq::Testing.fake! do
          final_delay = model.queue_background_migration_jobs_by_range_at_intervals(User.none, 'FooJob', 10.minutes)

          expect(final_delay).to eq(0)
        end
      end

      context 'with batch_size option' do
        it 'queues jobs correctly' do
          Sidekiq::Testing.fake! do
            model.queue_background_migration_jobs_by_range_at_intervals(User, 'FooJob', 10.minutes, batch_size: 2)

            expect(BackgroundMigrationWorker.jobs[0]['args']).to eq(['FooJob', [id1, id2]])
            expect(BackgroundMigrationWorker.jobs[0]['at']).to eq(10.minutes.from_now.to_f)
            expect(BackgroundMigrationWorker.jobs[1]['args']).to eq(['FooJob', [id3, id3]])
            expect(BackgroundMigrationWorker.jobs[1]['at']).to eq(20.minutes.from_now.to_f)
          end
        end
      end

      context 'without batch_size option' do
        it 'queues jobs correctly' do
          Sidekiq::Testing.fake! do
            model.queue_background_migration_jobs_by_range_at_intervals(User, 'FooJob', 10.minutes)

            expect(BackgroundMigrationWorker.jobs[0]['args']).to eq(['FooJob', [id1, id3]])
            expect(BackgroundMigrationWorker.jobs[0]['at']).to eq(10.minutes.from_now.to_f)
          end
        end
      end

      context 'with other_job_arguments option' do
        it 'queues jobs correctly' do
          Sidekiq::Testing.fake! do
            model.queue_background_migration_jobs_by_range_at_intervals(User, 'FooJob', 10.minutes, other_job_arguments: [1, 2])

            expect(BackgroundMigrationWorker.jobs[0]['args']).to eq(['FooJob', [id1, id3, 1, 2]])
            expect(BackgroundMigrationWorker.jobs[0]['at']).to eq(10.minutes.from_now.to_f)
          end
        end
      end

      context 'with initial_delay option' do
        it 'queues jobs correctly' do
          Sidekiq::Testing.fake! do
            model.queue_background_migration_jobs_by_range_at_intervals(User, 'FooJob', 10.minutes, other_job_arguments: [1, 2], initial_delay: 10.minutes)

            expect(BackgroundMigrationWorker.jobs[0]['args']).to eq(['FooJob', [id1, id3, 1, 2]])
            expect(BackgroundMigrationWorker.jobs[0]['at']).to eq(20.minutes.from_now.to_f)
          end
        end
      end

      context 'with track_jobs option' do
        it 'creates a record for each job in the database' do
          Sidekiq::Testing.fake! do
            expect do
              model.queue_background_migration_jobs_by_range_at_intervals(User, '::FooJob', 10.minutes,
                other_job_arguments: [1, 2], track_jobs: true)
            end.to change { Gitlab::Database::BackgroundMigrationJob.count }.from(0).to(1)

            expect(BackgroundMigrationWorker.jobs.size).to eq(1)

            tracked_job = Gitlab::Database::BackgroundMigrationJob.first

            expect(tracked_job.class_name).to eq('FooJob')
            expect(tracked_job.arguments).to eq([id1, id3, 1, 2])
            expect(tracked_job).to be_pending
          end
        end
      end

      context 'without track_jobs option' do
        it 'does not create records in the database' do
          Sidekiq::Testing.fake! do
            expect do
              model.queue_background_migration_jobs_by_range_at_intervals(User, 'FooJob', 10.minutes, other_job_arguments: [1, 2])
            end.not_to change { Gitlab::Database::BackgroundMigrationJob.count }

            expect(BackgroundMigrationWorker.jobs.size).to eq(1)
          end
        end
      end
    end

    context 'when the model specifies a primary_column_name' do
      let!(:id1) { create(:container_expiration_policy).id }
      let!(:id2) { create(:container_expiration_policy).id }
      let!(:id3) { create(:container_expiration_policy).id }

      around do |example|
        freeze_time { example.run }
      end

      before do
        ContainerExpirationPolicy.class_eval do
          include EachBatch
        end
      end

      it 'returns the final expected delay', :aggregate_failures do
        Sidekiq::Testing.fake! do
          final_delay = model.queue_background_migration_jobs_by_range_at_intervals(ContainerExpirationPolicy, 'FooJob', 10.minutes, batch_size: 2, primary_column_name: :project_id)

          expect(final_delay.to_f).to eq(20.minutes.to_f)
          expect(BackgroundMigrationWorker.jobs[0]['args']).to eq(['FooJob', [id1, id2]])
          expect(BackgroundMigrationWorker.jobs[0]['at']).to eq(10.minutes.from_now.to_f)
          expect(BackgroundMigrationWorker.jobs[1]['args']).to eq(['FooJob', [id3, id3]])
          expect(BackgroundMigrationWorker.jobs[1]['at']).to eq(20.minutes.from_now.to_f)
        end
      end

      context "when the primary_column_name is not an integer" do
        it 'raises error' do
          expect do
            model.queue_background_migration_jobs_by_range_at_intervals(ContainerExpirationPolicy, 'FooJob', 10.minutes, primary_column_name: :enabled)
          end.to raise_error(StandardError, /is not an integer column/)
        end
      end

      context "when the primary_column_name does not exist" do
        it 'raises error' do
          expect do
            model.queue_background_migration_jobs_by_range_at_intervals(ContainerExpirationPolicy, 'FooJob', 10.minutes, primary_column_name: :foo)
          end.to raise_error(StandardError, /does not have an ID column of foo/)
        end
      end
    end

    context "when the model doesn't have an ID or primary_column_name column" do
      it 'raises error (for now)' do
        expect do
          model.queue_background_migration_jobs_by_range_at_intervals(ProjectAuthorization, 'FooJob', 10.seconds)
        end.to raise_error(StandardError, /does not have an ID/)
      end
    end
  end

  describe '#perform_background_migration_inline?' do
    it 'returns true in a test environment' do
      stub_rails_env('test')

      expect(model.perform_background_migration_inline?).to eq(true)
    end

    it 'returns true in a development environment' do
      stub_rails_env('development')

      expect(model.perform_background_migration_inline?).to eq(true)
    end

    it 'returns false in a production environment' do
      stub_rails_env('production')

      expect(model.perform_background_migration_inline?).to eq(false)
    end
  end

  describe '#queue_batched_background_migration' do
    it 'creates the database record for the migration' do
      expect do
        model.queue_batched_background_migration(
          'MyJobClass',
          :projects,
          :id,
          job_interval: 5.minutes,
          batch_min_value: 5,
          batch_max_value: 1000,
          batch_class_name: 'MyBatchClass',
          batch_size: 100,
          sub_batch_size: 10,
          other_job_arguments: %w[my arguments])
      end.to change { Gitlab::Database::BackgroundMigration::BatchedMigration.count }.from(0).to(1)

      expect(Gitlab::Database::BackgroundMigration::BatchedMigration.first).to have_attributes(
        job_class_name: 'MyJobClass',
        table_name: 'projects',
        column_name: 'id',
        interval: 300,
        min_value: 5,
        max_value: 1000,
        batch_class_name: 'MyBatchClass',
        batch_size: 100,
        sub_batch_size: 10,
        job_arguments: %w[my arguments],
        status: 'active')
    end

    context 'when the max_value is not given' do
      context 'when records exist in the database' do
        let!(:event1) { create(:event) }
        let!(:event2) { create(:event) }
        let!(:event3) { create(:event) }

        it 'creates the record with current max value' do
          expect do
            model.queue_batched_background_migration('MyJobClass', :events, :id, job_interval: 5.minutes)
          end.to change { Gitlab::Database::BackgroundMigration::BatchedMigration.count }.from(0).to(1)

          expect(Gitlab::Database::BackgroundMigration::BatchedMigration.first).to have_attributes(
            job_class_name: 'MyJobClass',
            table_name: 'events',
            column_name: 'id',
            interval: 300,
            min_value: 1,
            max_value: event3.id,
            batch_class_name: described_class::BACKGROUND_MIGRATION_BATCH_CLASS_NAME,
            batch_size: described_class::BACKGROUND_MIGRATION_BATCH_SIZE,
            sub_batch_size: described_class::BACKGROUND_MIGRATION_SUB_BATCH_SIZE,
            job_arguments: [],
            status: 'active')
        end
      end

      context 'when the database is empty' do
        it 'does not create the record' do
          expect do
            model.queue_batched_background_migration('MyJobClass', :events, :id, job_interval: 5.minutes)
          end.not_to change { Gitlab::Database::BackgroundMigration::BatchedMigration.count }
        end
      end
    end
  end

  describe '#abort_batched_background_migrations' do
    let!(:migration1) { create(:batched_background_migration, :finished) }
    let!(:migration2) { create(:batched_background_migration) }
    let!(:migration3) { create(:batched_background_migration, job_class_name: 'SomeOtherJobClassName') }
    let!(:migration4) { create(:batched_background_migration, table_name: 'some_other_table_name') }

    it 'aborts unfinished migrations that match the job class and table configuration' do
      job_class_name = 'Gitlab::BackgroundMigration::CopyColumnUsingBackgroundMigrationJob'

      expect do
        model.abort_batched_background_migrations(job_class_name, 'events', 'id')
      end.to change { Gitlab::Database::BackgroundMigration::BatchedMigration.aborted.count }.from(0).to(1)

      expect(migration2.reload).to be_aborted
    end
  end

  describe '#migrate_async' do
    it 'calls BackgroundMigrationWorker.perform_async' do
      expect(BackgroundMigrationWorker).to receive(:perform_async).with("Class", "hello", "world")

      model.migrate_async("Class", "hello", "world")
    end

    it 'pushes a context with the current class name as caller_id' do
      expect(Gitlab::ApplicationContext).to receive(:with_context).with(caller_id: model.class.to_s)

      model.migrate_async('Class', 'hello', 'world')
    end
  end

  describe '#migrate_in' do
    it 'calls BackgroundMigrationWorker.perform_in' do
      expect(BackgroundMigrationWorker).to receive(:perform_in).with(10.minutes, 'Class', 'Hello', 'World')

      model.migrate_in(10.minutes, 'Class', 'Hello', 'World')
    end

    it 'pushes a context with the current class name as caller_id' do
      expect(Gitlab::ApplicationContext).to receive(:with_context).with(caller_id: model.class.to_s)

      model.migrate_in(10.minutes, 'Class', 'Hello', 'World')
    end
  end

  describe '#bulk_migrate_async' do
    it 'calls BackgroundMigrationWorker.bulk_perform_async' do
      expect(BackgroundMigrationWorker).to receive(:bulk_perform_async).with([%w(Class hello world)])

      model.bulk_migrate_async([%w(Class hello world)])
    end

    it 'pushes a context with the current class name as caller_id' do
      expect(Gitlab::ApplicationContext).to receive(:with_context).with(caller_id: model.class.to_s)

      model.bulk_migrate_async([%w(Class hello world)])
    end
  end

  describe '#bulk_migrate_in' do
    it 'calls BackgroundMigrationWorker.bulk_perform_in_' do
      expect(BackgroundMigrationWorker).to receive(:bulk_perform_in).with(10.minutes, [%w(Class hello world)])

      model.bulk_migrate_in(10.minutes, [%w(Class hello world)])
    end

    it 'pushes a context with the current class name as caller_id' do
      expect(Gitlab::ApplicationContext).to receive(:with_context).with(caller_id: model.class.to_s)

      model.bulk_migrate_in(10.minutes, [%w(Class hello world)])
    end
  end
end
