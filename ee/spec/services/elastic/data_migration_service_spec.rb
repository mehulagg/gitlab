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

  describe '.migration_has_finished?' do
    let(:migration) { subject.migrations.first }
    let(:migration_name) { migration.name.underscore }

    it 'returns true if migration has finished' do
      expect(subject.migration_has_finished?(migration_name)).to eq(false)

      migration.save!(completed: false)
      refresh_index!

      expect(subject.migration_has_finished?(migration_name)).to eq(false)

      migration.save!(completed: true)
      refresh_index!

      expect(subject.migration_has_finished?(migration_name)).to eq(true)
    end
  end

  describe 'mark_all_as_completed!' do
    it 'creates all migration versions' do
      expect(Elastic::MigrationRecord.persisted_versions(completed: true).count).to eq(0)

      subject.mark_all_as_completed!
      refresh_index!

      expect(Elastic::MigrationRecord.persisted_versions(completed: true).count).to eq(subject.migrations.count)
    end
  end
end
