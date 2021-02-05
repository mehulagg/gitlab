# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20201123123400_migrate_issues_to_separate_index.rb')

RSpec.describe MigrateIssuesToSeparateIndex, :elastic, :sidekiq_inline do
  let(:version) { 20201123123400 }
  let(:migration) { described_class.new(version) }
  let(:issues) { create_list(:issue, 3) }
  let(:index_name) { "#{es_helper.target_name}-issues" }

  before do
    allow(Elastic::DataMigrationService).to receive(:migration_has_finished?)
      .with(:migrate_issues_to_separate_index)
      .and_return(false)

    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)

    issues

    ensure_elasticsearch_index!
  end

  describe 'migration_options' do
    it 'has migration options set', :aggregate_failures do
      expect(migration.batched?).to be_truthy
      expect(migration.throttle_delay).to eq(1.minute)
      expect(migration.pause_indexing?).to be_truthy
    end
  end

  describe '.migrate', :clean_gitlab_redis_shared_state do
    context 'initial launch' do
      before do
        es_helper.delete_index(index_name: es_helper.target_index_name(target: index_name))
      end

      it 'creates an index and sets migration_state' do
        expect { migration.migrate }.to change { es_helper.alias_exists?(name: index_name) }.from(false).to(true)

        expect(migration.migration_state).to include(slice: 0, max_slices: 5)
      end
    end

    context 'batch run' do
      it 'migrates all issues' do
        total_shards = es_helper.get_settings.dig('number_of_shards').to_i
        migration.set_migration_state(slice: 0, max_slices: total_shards)

        total_shards.times do |i|
          migration.migrate
        end

        expect(migration.completed?).to be_truthy
        expect(es_helper.documents_count(index_name: "#{es_helper.target_name}-issues")).to eq(issues.count)
      end
    end

    context 'failed run' do
      let(:client) { double('Elasticsearch::Transport::Client') }

      before do
        allow(migration).to receive(:client).and_return(client)
      end

      context 'exception is raised' do
        before do
          allow(client).to receive(:reindex).and_raise(StandardError)
        end

        it 'increases retry_attempt' do
          migration.set_migration_state(slice: 0, max_slices: 2, retry_attempt: 1)

          expect { migration.migrate }.to raise_error(StandardError)
          expect(migration.migration_state).to match(slice: 0, max_slices: 2, retry_attempt: 2)
        end

        it 'fails the migration after too many attempts' do
          migration.set_migration_state(slice: 0, max_slices: 2, retry_attempt: 30)

          migration.migrate

          expect(migration.migration_state).to match(slice: 0, max_slices: 2, retry_attempt: 30, halted: true, halted_indexing_unpaused: false)
          expect(migration).not_to receive(:process_response)
        end
      end

      context 'elasticsearch failures' do
        context 'total is not equal' do
          before do
            allow(client).to receive(:reindex).and_return({ "total" => 60, "updated" => 0, "created" => 45, "deleted" => 0, "failures" => [] })
          end

          it 'raises an error' do
            migration.set_migration_state(slice: 0, max_slices: 2)

            expect { migration.migrate }.to raise_error(/total is not equal/)
          end
        end

        context 'reindexing failues' do
          before do
            allow(client).to receive(:reindex).and_return({ "total" => 60, "updated" => 0, "created" => 0, "deleted" => 0, "failures" => [{ "type": "es_rejected_execution_exception" }] })
          end

          it 'raises an error' do
            migration.set_migration_state(slice: 0, max_slices: 2)

            expect { migration.migrate }.to raise_error(/failed with/)
          end
        end
      end
    end
  end

  describe '.completed?' do
    subject { migration.completed? }

    before do
      2.times do |slice|
        migration.set_migration_state(slice: slice, max_slices: 2)
        migration.migrate
      end
    end

    context 'counts are equal' do
      let(:issues_count) { issues.count }

      it 'returns true' do
        is_expected.to be_truthy
      end
    end
  end
end
