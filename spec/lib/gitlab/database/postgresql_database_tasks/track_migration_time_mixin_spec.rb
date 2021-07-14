# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::PostgresqlDatabaseTasks::TrackMigrationTimeMixin do
  describe 'migration mixin' do
    let(:instance_class) do
      klass = Class.new do
        def version
          4711
        end

        def exec_migration
          original_exec_migration
        end

        def original_exec_migration
        end
      end

      klass.prepend(described_class)

      klass
    end

    let(:instance) { instance_class.new }

    it 'calls original method' do
      expect(instance).to receive(:original_exec_migration)

      instance.exec_migration
    end

    it 'tracks migration start time' do
      freeze_time do
        instance.exec_migration

        expect(ActiveRecord::SchemaMigration.migration_start_times[instance.version]).to eq(Time.zone.now)
      end
    end
  end
end
