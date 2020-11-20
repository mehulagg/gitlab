# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::MigrationWorker, :elastic do
  subject { described_class.new }

  describe '#perform' do
    context 'indexing is disabled' do
      before do
        stub_ee_application_setting(elasticsearch_indexing: false)
      end

      it 'returns without execution' do
        expect(subject).not_to receive(:execute_migration)
        expect(subject.perform).to be_falsey
      end
    end

    context 'indexing is enabled' do
      before do
        stub_ee_application_setting(elasticsearch_indexing: true)
      end

      it 'creates an index if it does not exist' do
        Gitlab::Elastic::Helper.default.delete_index(index_name: es_helper.migrations_index_name)

        expect { subject.perform }.to change { Gitlab::Elastic::Helper.default.index_exists?(index_name: es_helper.migrations_index_name) }.from(false).to(true)
      end

      context 'no unexecuted migrations' do
        before do
          allow(subject).to receive(:current_migration).and_return(nil)
        end

        it 'skips execution' do
          expect(subject).not_to receive(:execute_migration)

          expect(subject.perform).to be_falsey
        end
      end

      context 'migration process' do
        let(:migration) { Elastic::DataMigrationService.migrations.first }

        before do
          allow(subject).to receive(:current_migration).and_return(migration)
          allow(migration).to receive(:persisted?).and_return(persisted)
          allow(migration).to receive(:completed?).and_return(completed)
        end

        using RSpec::Parameterized::TableSyntax

        where(:persisted, :completed, :execute_migration) do
          false | false | true
          false | true  | true
          true  | false | false
          true  | true  | false
        end

        with_them do
          it 'calls migration only when needed' do
            if execute_migration
              expect(migration).to receive(:migrate).once
            else
              expect(migration).not_to receive(:migrate)
            end

            expect(migration).to receive(:save!).with(completed: completed)
            expect(Elastic::DataMigrationService).to receive(:drop_migration_has_finished_cache!).with(migration)

            subject.perform
          end
        end
      end
    end
  end
end
