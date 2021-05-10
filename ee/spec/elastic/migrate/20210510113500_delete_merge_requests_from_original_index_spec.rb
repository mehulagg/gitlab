# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20210510113500_delete_merge_requests_from_original_index.rb')

RSpec.describe DeleteMergeRequestsFromOriginalIndex, :elastic, :sidekiq_inline do
  let(:version) { 20210510113500 }
  let(:migration) { described_class.new(version) }
  let(:helper) { Gitlab::Elastic::Helper.new }

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
    allow(migration).to receive(:helper).and_return(helper)
  end

  describe 'migration_options' do
    it 'has migration options set', :aggregate_failures do
      expect(migration.batched?).to be_truthy
      expect(migration.throttle_delay).to eq(3.minutes)
    end
  end

  context 'merge requests are already deleted' do
    it 'does not execute delete_by_query' do
      expect(migration.completed?).to be_truthy
      expect(helper.client).not_to receive(:delete_by_query)

      migration.migrate
    end
  end

  context 'merge requests are still present in the index' do
    let(:merge_requests) { create_list(:merge_request, 3) }

    before do
      allow(Elastic::DataMigrationService).to receive(:migration_has_finished?)
        .with(:migrate_merge_requests_to_separate_index)
        .and_return(false)

      # ensure merge requests are indexed
      merge_requests

      ensure_elasticsearch_index!
    end

    it 'removes merge requests from the index' do
      expect { migration.migrate }.to change { migration.completed? }.from(false).to(true)
    end
  end

  context 'migration fails' do
    let(:client) { double('Elasticsearch::Transport::Client') }

    before do
      allow(migration).to receive(:client).and_return(client)
      allow(migration).to receive(:completed?).and_return(false)
    end

    context 'exception is raised' do
      before do
        allow(client).to receive(:delete_by_query).and_raise(StandardError)
      end

      it 'increases retry_attempt' do
        migration.set_migration_state(retry_attempt: 1)

        expect { migration.migrate }.to raise_error(StandardError)
        expect(migration.migration_state).to match(retry_attempt: 2)
      end

      it 'fails the migration after too many attempts' do
        # run migration up to the set MAX_ATTEMPTS set in the migration
        DeleteMergeRequestsFromOriginalIndex::MAX_ATTEMPTS.times do
          expect { migration.migrate }.to raise_error(StandardError)
        end

        migration.migrate

        expect(migration.migration_state).to match(retry_attempt: 30, halted: true, halted_indexing_unpaused: false)
        expect(client).not_to receive(:delete_by_query)
      end
    end

    context 'es responds with errors' do
      before do
        allow(client).to receive(:delete_by_query).and_return('failures' => ['failed'])
      end

      it 'raises an error and increases retry attempt' do
        expect { migration.migrate }.to raise_error(/Failed to delete merge requests/)
        expect(migration.migration_state).to match(retry_attempt: 1)
      end
    end
  end
end
