# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::MigrationRecord, :elastic do
  let(:record) { described_class.new(version: Time.now.to_i, name: 'ExampleMigration', filename: nil) }

  describe '#save!' do
    it 'creates an index if it is not found' do
      es_helper.delete_index(index_name: @migrations_index_name)

      expect { record.save!(completed: true) }.to raise_error(/index is not found/)
    end
  end

  describe '#persisted?' do
    it 'changes on object save' do
      expect { record.save!(completed: true) }.to change { record.persisted? }.from(false).to(true)
    end
  end

  describe '.persisted_versions' do
    let(:completed_versions) { 1.upto(5).map { |i| described_class.new(version: i, name: i, filename: nil) } }
    let(:in_progress_migration) { described_class.new(version: 10, name: 10, filename: nil) }

    before do
      completed_versions.each { |migration| migration.save!(completed: true) }
      in_progress_migration.save!(completed: false)

      es_helper.refresh_index(index_name: @migrations_index_name)
    end

    it 'loads all records' do
      expect(described_class.persisted_versions(completed: true)).to match_array(completed_versions.map(&:version))
      expect(described_class.persisted_versions(completed: false)).to contain_exactly(in_progress_migration.version)
    end

    it 'returns empty array if no index present' do
      es_helper.delete_index(index_name: @migrations_index_name)

      expect(described_class.persisted_versions(completed: true)).to eq([])
      expect(described_class.persisted_versions(completed: false)).to eq([])
    end
  end
end
