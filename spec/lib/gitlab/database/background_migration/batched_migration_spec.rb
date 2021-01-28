# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::BackgroundMigration::BatchedMigration, type: :model do
  it_behaves_like 'having unique enum values'

  describe 'associations' do
    it { is_expected.to have_many(:batched_jobs).with_foreign_key(:batched_background_migration_id) }
  end

  describe '#create_batched_job!' do
    let(:batched_migration) { create(:batched_background_migration) }

    it 'creates a batched_job with the correct batch configuration' do
      batched_job = batched_migration.create_batched_job!(1, 5)

      expect(batched_job).to have_attributes(
        min_value: 1,
        max_value: 5,
        batch_size: batched_migration.batch_size,
        sub_batch_size: batched_migration.sub_batch_size)
    end
  end

  describe '#last_created_job' do
    let!(:batched_migration) { create(:batched_background_migration) }
    let!(:batched_job1) { create(:batched_background_migration_job, batched_migration: batched_migration) }
    let!(:batched_job2) { create(:batched_background_migration_job, batched_migration: batched_migration, created_at: 1.month.ago) }

    it 'returns the most recently created batch_job' do
      expect(batched_migration.last_created_job).to eq(batched_job1)
    end
  end

  describe '#job_class' do
    let(:job_class) { Gitlab::BackgroundMigration::CopyColumnUsingBackgroundMigrationJob }
    let(:batched_migration) { build(:batched_background_migration) }

    it 'returns the class of the job for the migration' do
      expect(batched_migration.job_class).to eq(job_class)
    end
  end

  shared_examples_for 'an attr_writer that normalizes assigned class names' do |attribute_name|
    let(:batched_migration) { build(:batched_background_migration) }

    context 'when the toplevel namespace prefix exists' do
      it 'removes the leading prefix' do
        batched_migration.public_send(:"#{attribute_name}=", '::Foo::Bar')

        expect(batched_migration[attribute_name]).to eq('Foo::Bar')
      end
    end

    context 'when the toplevel namespace prefix does not exist' do
      it 'does not change the given class name' do
        batched_migration.public_send(:"#{attribute_name}=", '::Foo::Bar')

        expect(batched_migration[attribute_name]).to eq('Foo::Bar')
      end
    end
  end

  describe '#job_class_name=' do
    it_behaves_like 'an attr_writer that normalizes assigned class names', :job_class_name
  end

  describe '#batch_class_name=' do
    it_behaves_like 'an attr_writer that normalizes assigned class names', :batch_class_name
  end
end
