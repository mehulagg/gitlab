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
      let(:migration) { Elastic::DataMigrationService.migrations.first }

      before do
        stub_ee_application_setting(elasticsearch_indexing: true)

        allow(subject).to receive(:current_migration).and_return(migration)
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

      context 'migration is halted' do
        before do
          allow(Gitlab::CurrentSettings).to receive(:elasticsearch_pause_indexing?).and_return(true)
          allow(subject).to receive(:current_migration).and_return(migration)
          allow(migration).to receive(:pause_indexing?).and_return(true)
          allow(migration).to receive(:halted?).and_return(true)
        end

        it 'skips execution' do
          expect(migration).not_to receive(:migrate)

          subject.perform
        end

        context 'pause indexing is not allowed' do
          before do
            migration.save_state!(pause_indexing: false)
          end

          it 'does not unpauses indexing' do
            expect(Gitlab::CurrentSettings).not_to receive(:update!)

            subject.perform
          end
        end

        context 'pause indexing is allowed' do
          before do
            migration.save_state!(pause_indexing: true)
          end

          it 'unpauses indexing' do
            expect(Gitlab::CurrentSettings).to receive(:update!).with(elasticsearch_pause_indexing: false)

            subject.perform
          end
        end
      end

      context 'migration process' do
        before do
          allow(migration).to receive(:persisted?).and_return(persisted)
          allow(migration).to receive(:completed?).and_return(completed)
          allow(migration).to receive(:batched?).and_return(batched)
        end

        using RSpec::Parameterized::TableSyntax

        # completed is evaluated after migrate method is executed
        where(:persisted, :completed, :execute_migration, :batched) do
          false | false | true  | false
          false | true  | true  | false
          false | false | true  | true
          false | true  | true  | true
          true  | false | false | false
          true  | true  | false | false
          true  | false | true  | true
          true  | true  | true | true
        end

        with_them do
          it 'calls migration only when needed', :aggregate_failures do
            if execute_migration
              expect(migration).to receive(:migrate).once
            else
              expect(migration).not_to receive(:migrate)
            end

            expect(migration).to receive(:save!).with(completed: completed)
            expect(Elastic::DataMigrationService).to receive(:drop_migration_has_finished_cache!).with(migration)

            subject.perform
          end

          it 'handles batched migrations' do
            if batched && !completed
              # default throttle_delay is 5.minutes
              expect( Elastic::MigrationWorker).to receive(:perform_in)
                .with(5.minutes)
            else
              expect( Elastic::MigrationWorker).not_to receive(:perform_in)
            end

            subject.perform
          end
        end

        context 'indexing pause' do
          before do
            allow(migration).to receive(:pause_indexing?).and_return(true)
          end

          let(:batched) { true }

          where(:persisted, :completed, :expected) do
            false | false | false
            true  | false | false
            true  | true  | true
          end

          with_them do
            it 'pauses and unpauses indexing' do
              expect(Gitlab::CurrentSettings).to receive(:update!).with(elasticsearch_pause_indexing: true)
              expect(Gitlab::CurrentSettings).to receive(:update!).with(elasticsearch_pause_indexing: false) if expected

              subject.perform
            end
          end
        end
      end
    end
  end
end
