# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::BackgroundMigration::BatchedMigrationWrapper, '#perform' do
  let(:migration_wrapper) { described_class.new }
  let(:job_class) { Gitlab::BackgroundMigration::CopyColumnUsingBackgroundMigrationJob }

  let_it_be(:active_migration) { create(:batched_background_migration, :active, job_arguments: [:id, :other_id]) }

  let!(:job_record) { create(:batched_background_migration_job, batched_migration: active_migration) }
  let(:job_instance) { double('job instance', batch_metrics: {}) }

  before do
    allow(job_class).to receive(:new).and_return(job_instance)
  end

  it 'runs the migration job' do
    expect(job_instance).to receive(:perform).with(1, 10, 'events', 'id', 1, 'id', 'other_id')

    migration_wrapper.perform(job_record)
  end

  it 'updates the tracking record in the database' do
    test_metrics = { 'my_metris' => 'some value' }

    expect(job_instance).to receive(:perform)
    expect(job_instance).to receive(:batch_metrics).and_return(test_metrics)

    expect(job_record).to receive(:update!).with(hash_including(attempts: 1, status: :running)).and_call_original

    freeze_time do
      migration_wrapper.perform(job_record)

      reloaded_job_record = job_record.reload

      expect(reloaded_job_record).not_to be_pending
      expect(reloaded_job_record.attempts).to eq(1)
      expect(reloaded_job_record.started_at).to eq(Time.current)
      expect(reloaded_job_record.metrics).to eq(test_metrics)
    end
  end

  context 'reporting prometheus metrics' do
    let(:labels) { job_record.batched_migration.prometheus_labels }

    before do
      allow(job_instance).to receive(:perform)
      job_record.started_at = Time.current - 5.seconds
      job_record.finished_at = Time.current

    end

    it 'reports batch_size' do
      expect(described_class.metrics[:gauge_batch_size]).to receive(:set).with(labels, job_record.batch_size)

      migration_wrapper.perform(job_record)
    end

    it 'reports sub_batch_size' do
      expect(described_class.metrics[:gauge_sub_batch_size]).to receive(:set).with(labels, job_record.sub_batch_size)

      migration_wrapper.perform(job_record)
    end

    it 'reports updated tuples (currently based on batch_size)' do
      expect(described_class.metrics[:counter_updated_tuples]).to receive(:increment).with(labels, job_record.batch_size)

      migration_wrapper.perform(job_record)
    end

    it 'reports summary of query timings' do
      metrics = { 'timings' => { 'update_all' => [1, 2, 3, 4, 5] } }

      expect(job_instance).to receive(:batch_metrics).and_return(metrics)

      metrics['timings'].each do |key, timings|
        summary_labels = labels.merge(operation: key)
        timings.each do |timing|
          expect(described_class.metrics[:histogram_timings]).to receive(:observe).with(summary_labels, timing)
        end
      end

      migration_wrapper.perform(job_record)
    end

    it 'reports time efficiency' do
      freeze_time do
        expect(Time).to receive(:current).and_return(Time.zone.now - 5.seconds).ordered
        expect(Time).to receive(:current).and_return(Time.zone.now).ordered

        ratio = 5 / job_record.batched_migration.interval.to_f

        expect(described_class.metrics[:histogram_time_efficiency]).to receive(:observe).with(labels, ratio)

        migration_wrapper.perform(job_record)
      end
    end
  end

  context 'when the migration job does not raise an error' do
    it 'marks the tracking record as succeeded' do
      expect(job_instance).to receive(:perform).with(1, 10, 'events', 'id', 1, 'id', 'other_id')

      freeze_time do
        migration_wrapper.perform(job_record)

        reloaded_job_record = job_record.reload

        expect(reloaded_job_record).to be_succeeded
        expect(reloaded_job_record.finished_at).to eq(Time.current)
      end
    end
  end

  context 'when the migration job raises an error' do
    it 'marks the tracking record as failed before raising the error' do
      expect(job_instance).to receive(:perform)
        .with(1, 10, 'events', 'id', 1, 'id', 'other_id')
        .and_raise(RuntimeError, 'Something broke!')

      freeze_time do
        expect { migration_wrapper.perform(job_record) }.to raise_error(RuntimeError, 'Something broke!')

        reloaded_job_record = job_record.reload

        expect(reloaded_job_record).to be_failed
        expect(reloaded_job_record.finished_at).to eq(Time.current)
      end
    end
  end
end
