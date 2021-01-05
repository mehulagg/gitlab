# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::DataMigrationService, :elastic do
  subject { described_class }

  describe '.migrations' do
    it 'all migration names are unique' do
      expect(subject.migrations.count).to eq(subject.migrations.map(&:name).uniq.count)
    end

    context 'migration_files stubbed' do
      let(:migration_files) { %w(ee/elastic/migrate/20201105180000_example_migration.rb ee/elastic/migrate/20201201130000_example_migration.rb) }

      before do
        allow(subject).to receive(:migration_files).and_return(migration_files)
      end

      it 'creates migration records' do
        migrations = subject.migrations
        migration = migrations.first

        expect(migrations.count).to eq(2)
        expect(migration.version).to eq(20201105180000)
        expect(migration.name).to eq('ExampleMigration')
        expect(migration.filename).to eq(migration_files.first)
      end
    end
  end

  describe '.migration_has_finished_uncached?' do
    let(:migration) { subject.migrations.first }
    let(:migration_name) { migration.name.underscore }

    it 'returns true if migration has finished' do
      expect(subject.migration_has_finished_uncached?(migration_name)).to eq(true)

      migration.save!(completed: false)
      refresh_index!

      expect(subject.migration_has_finished_uncached?(migration_name)).to eq(false)

      migration.save!(completed: true)
      refresh_index!

      expect(subject.migration_has_finished_uncached?(migration_name)).to eq(true)
    end
  end

  describe '.migration_has_finished?' do
    let(:migration) { subject.migrations.first }
    let(:migration_name) { migration.name.underscore }
    let(:finished) { true }

    before do
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
      allow(subject).to receive(:migration_has_finished_uncached?).with(migration_name).and_return(finished)
    end

    it 'calls the uncached method only once' do
      expect(subject).to receive(:migration_has_finished_uncached?).once

      expect(subject.migration_has_finished?(migration_name)).to eq(finished)
      expect(subject.migration_has_finished?(migration_name)).to eq(finished)
    end
  end

  describe '.mark_all_as_completed!' do
    before do
      # Clear out the migrations index since it is setup initially with
      # everything finished migrating
      es_helper.delete_migrations_index
      es_helper.create_migrations_index
    end

    it 'creates all migration versions' do
      expect(Elastic::MigrationRecord.persisted_versions(completed: true).count).to eq(0)

      subject.mark_all_as_completed!
      refresh_index!

      expect(Elastic::MigrationRecord.persisted_versions(completed: true).count).to eq(subject.migrations.count)
    end

    it 'drops all cache keys' do
      allow(subject).to receive(:migrations).and_return(
        [
          Elastic::MigrationRecord.new(version: 100, name: 'SomeMigration', filename: nil),
          Elastic::MigrationRecord.new(version: 200, name: 'SomeOtherMigration', filename: nil)
        ]
      )

      subject.migrations.each do |migration|
        expect(subject).to receive(:drop_migration_has_finished_cache!).with(migration)
      end

      subject.mark_all_as_completed!
    end
  end

  describe '.drop_migration_has_finished_cache!' do
    let(:migration) { subject.migrations.first }
    let(:migration_name) { migration.name.underscore }
    let(:finished) { true }

    before do
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
      allow(subject).to receive(:migration_has_finished_uncached?).with(migration_name).and_return(finished)
    end

    it 'drops cache' do
      expect(subject).to receive(:migration_has_finished_uncached?).twice

      expect(subject.migration_has_finished?(migration_name)).to eq(finished)

      subject.drop_migration_has_finished_cache!(migration)

      expect(subject.migration_has_finished?(migration_name)).to eq(finished)
    end
  end
end
