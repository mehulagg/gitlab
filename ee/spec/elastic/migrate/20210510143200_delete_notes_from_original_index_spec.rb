# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20210510143200_delete_notes_from_original_index.rb')

RSpec.describe DeleteNotesFromOriginalIndex, :elastic, :sidekiq_inline do
  let(:version) { 20210510143200 }
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

  context 'notes are already deleted' do
    it 'does not execute delete_by_query' do
      expect(migration.completed?).to be_truthy
      expect(helper.client).not_to receive(:delete_by_query)

      migration.migrate
    end
  end

  context 'notes are still present in the index' do
    # Create notes on different projects to ensure they are spread across all shards
    let!(:notes) { Array.new(10).map { create(:note, project: create(:project, :public)) } }

    before do
      set_elasticsearch_migration_to :migrate_notes_to_separate_index, including: false
      ensure_elasticsearch_index!
    end

    it 'removes notes from the index' do
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
        stub_const('DeleteNotesFromOriginalIndex::MAX_ATTEMPTS', 2)

        # run migration up to the set MAX_ATTEMPTS set in the migration
        DeleteNotesFromOriginalIndex::MAX_ATTEMPTS.times do
          expect { migration.migrate }.to raise_error(StandardError)
        end

        migration.migrate

        expect(migration.migration_state).to match(retry_attempt: 2, halted: true, halted_indexing_unpaused: false)
        expect(client).not_to receive(:delete_by_query)
      end
    end

    context 'es responds with errors' do
      before do
        allow(client).to receive(:delete_by_query).and_return('failures' => ['failed'])
      end

      it 'raises an error and increases retry attempt' do
        expect { migration.migrate }.to raise_error(/Failed to delete notes/)
        expect(migration.migration_state).to match(retry_attempt: 1)
      end
    end
  end
end
