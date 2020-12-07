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
      expect(migration.throttle_delay).to eq(10.minutes)
      expect(migration.pause_indexing?).to be_truthy
    end
  end

  describe '.migrate', :clean_gitlab_redis_shared_state do
    context 'initial launch' do
      before do
        allow(migration).to receive(:get_number_of_shards).and_return(10)
        es_helper.delete_index(index_name: es_helper.target_index_name(target: index_name))
      end

      it 'creates an index and sets next_launch_options' do
        expect { migration.migrate }.to change { es_helper.alias_exists?(name: index_name) }.from(false).to(true)

        expect(migration.launch_options).to include(slice: 0, max_slices: 10)
      end
    end

    context 'batch run' do
      it 'migrates all issues' do
        total_shards = es_helper.get_settings.dig('number_of_shards').to_i
        migration.set_launch_options(slice: 0, max_slices: total_shards)

        total_shards.times do |i|
          migration.migrate
        end

        expect(migration.completed?).to be_truthy
        expect(es_helper.documents_count(index_name: "#{es_helper.target_name}-issues")).to eq(issues.count)
      end
    end
  end

  describe '.completed?' do
    subject { migration.completed? }

    before do
      allow(migration).to receive(:new_issues_documents_count).and_return(issues_count)
    end

    context 'counts are equal' do
      let(:issues_count) { issues.count }

      it 'returns true' do
        is_expected.to be_truthy
      end
    end

    context 'counts are not equal' do
      let(:issues_count) { 1 }

      it 'returns true' do
        is_expected.to be_falsey
      end
    end
  end
end
