# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::MigrationBatchWorker, :elastic do
  subject { described_class.new }

  describe '#perform' do
    context 'indexing is disabled' do
      before do
        stub_ee_application_setting(elasticsearch_indexing: false)
      end

      it 'returns without execution' do
        expect(subject).not_to receive(:execute_migration)
        expect(subject.perform('1', 'name', 'filename')).to be_falsey
      end
    end

    context 'indexing is enabled' do
      let(:migration) { Elastic::DataMigrationService.migrations.first }

      before do
        stub_ee_application_setting(elasticsearch_indexing: true)
      end

      it 'creates an index if it does not exist' do
        Gitlab::Elastic::Helper.default.delete_index(index_name: @migrations_index_name)

        expect { subject.perform(migration.version, migration.name, migration.filename) }.to change { Gitlab::Elastic::Helper.default.index_exists?(index_name: @migrations_index_name) }.from(false).to(true)
      end

      context 'migration batch process' do
        before do
          allow(migration).to receive(:completed?).and_return(completed)
        end

        using RSpec::Parameterized::TableSyntax

        where(:completed) do
          [true, false]
        end

        with_them do
          it 'updates migration record as complete only when completed', :aggregate_failures do
            expect_next_instance_of(Elastic::MigrationRecord) do |migration_record|
              expect(migration_record).to receive(:migrate).once

              if completed
                expect(migration_record).to receive(:save!).with(completed: true)
              else
                expect(migration_record).not_to receive(:save!)
                expect(Elastic::MigrationBatchWorker).to receive(:perform_in).with(5.minutes, migration.version, migration.name, migration.filename)
              end
            end

            subject.perform(migration.version, migration.name, migration.filename)
          end
        end
      end
    end
  end
end
