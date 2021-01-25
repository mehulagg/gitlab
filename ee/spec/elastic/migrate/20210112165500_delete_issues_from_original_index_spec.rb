# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20210112165500_delete_issues_from_original_index.rb')

RSpec.describe DeleteIssuesFromOriginalIndex, :elastic, :sidekiq_inline do
  let(:version) { 20210112165500 }
  let(:migration) { described_class.new(version) }
  let(:helper) { Gitlab::Elastic::Helper.new }

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
    allow(migration).to receive(:helper).and_return(helper)
  end

  describe 'migration_options' do
    it 'has migration options set', :aggregate_failures do
      expect(migration.batched?).to be_truthy
      expect(migration.throttle_delay).to eq(1.minute)
    end
  end

  context 'issues are already deleted' do
    it 'does not execute delete_by_query' do
      expect(migration.completed?).to be_truthy
      expect(helper.client).not_to receive(:delete_by_query)

      migration.migrate
    end
  end

  context 'issues are still present in the index' do
    let(:issues) { create_list(:issue, 3) }

    before do
      allow(Elastic::DataMigrationService).to receive(:migration_has_finished?)
        .with(:migrate_issues_to_separate_index)
        .and_return(false)

      # ensure issues are indexed
      issues

      ensure_elasticsearch_index!
    end

    it 'removes issues from the index' do
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
        migration.set_migration_state(retry_attempt: 30)

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
        expect { migration.migrate }.to raise_error(/Failed to delete issues/)
        expect(migration.migration_state).to match(retry_attempt: 1)
      end
    end
  end
end
