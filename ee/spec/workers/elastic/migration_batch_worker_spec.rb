# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::MigrationBatchWorker, :elastic do
  let(:migration) { Elastic::DataMigrationService.migrations.first }

  before do
    allow(Elastic::MigrationRecord).to receive(:new).and_return(migration)
  end

  subject { described_class.new }

  include_examples 'an idempotent worker' do
    let(:job_args) { [migration.version, migration.name, migration.filename] }

    describe '#perform' do
      context 'indexing is disabled' do
        before do
          stub_ee_application_setting(elasticsearch_indexing: false)
        end

        it 'returns without execution' do
          expect(migration).not_to receive(:migrate)

          # cannot check return value due to how idempotent shared examples work
          subject
        end
      end

      context 'indexing is enabled' do
        before do
          stub_ee_application_setting(elasticsearch_indexing: true)
        end

        context 'migration batch process' do
          using RSpec::Parameterized::TableSyntax

          before do
            allow(migration).to receive(:completed?).and_return(completed_before_attempting_migrate, completed_after_migrate)
          end

          where(:completed_before_attempting_migrate, :completed_after_migrate) do
            true  | true
            false | false
            false | true
          end

          with_them do
            it 'runs migration and updates completed state appropriately', :aggregate_failures do
              if completed_before_attempting_migrate
                expect(migration).not_to receive(:migrate)
              else
                # idempotent job but allow call to be received multiple times (it re-enqueues itself)
                expect(migration).to receive(:migrate).at_least(:once)

                if completed_after_migrate
                  expect(migration).to receive(:save!).with(completed: true)
                else
                  expect(migration).not_to receive(:save!)
                  # idempotent job but allow call to be received multiple times (it re-enqueues itself)
                  expect(Elastic::MigrationBatchWorker).to receive(:perform_in).at_least(:once).with(5.minutes, migration.version, migration.name, migration.filename)
                end
              end

              subject
            end
          end
        end
      end
    end
  end
end
