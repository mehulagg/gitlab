# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20201123123400_migrate_issues_to_separate_index.rb')

RSpec.describe MigrateIssuesToSeparateIndex, :elastic, :sidekiq_inline do
  let(:version) { 20201123123400 }
  let(:migration) { described_class.new(version) }
  let(:issues) { create_list(:issue, 3) }

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)

    issues

    ensure_elasticsearch_index!
  end

  describe 'migration_options' do
    it 'has migration options set', :aggregate_failures do
      expect(migration.batched?).to be_truthy
      expect(migration.throttle_delay).to eq(5.seconds)
    end
  end

  describe '.migrate' do
    context 'initial launch' do
      before do
        allow(migration).to receive(:launch_options).and_return({})
        allow(migration).to receive(:get_number_of_shards).and_return(10)
      end

      it 'pauses indexing and sets next_launch_options' do
        expect(Gitlab::CurrentSettings).to receive(:update!).with(elasticsearch_pause_indexing: true)

        migration.migrate

        expect(migration.next_launch_options).to eq({ slice: 0, max_slices: 10 })
      end
    end

    context 'batch run' do
      it 'migrates all issues' do
        total_shards = es_helper.get_settings.dig('number_of_shards').to_i
        migration.launch_options = { slice: 0, max_slices: total_shards }

        total_shards.times do |i|
          migration.migrate

          migration.launch_options = migration.next_launch_options
        end

        expect(migration.completed?).to be_truthy
      end
    end
  end
end
