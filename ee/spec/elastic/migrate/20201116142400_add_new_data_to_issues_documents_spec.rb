# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20201116142400_add_new_data_to_issues_documents.rb')

RSpec.describe AddNewDataToIssuesDocuments, :unit, :elastic do
  let(:logger) { double('Gitlab::Elasticsearch::Logger') }

  before do
    allow(::Gitlab::Elasticsearch::Logger).to receive(:build).and_return(logger)
    #
    # stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
  end
  let(:version) { 20201116142400 }
  let(:migration) { described_class.new(version) }

  describe 'migration_options' do
    it 'has migration options set', :aggregate_failures do
      expect(described_class.get_migration_options[:batched]).to be_truthy
      expect(described_class.get_migration_options[:throttle_time]).to eq(5.minutes)
    end
  end

  describe '.migrate' do
    subject { migration.migrate }

    context 'when migration is already completed' do
      before do
        allow(migration).to receive(:completed?).and_return(true)
      end

      it 'logs a message and does not modify data', :aggregate_failures do
        expect(logger).to receive(:info).with('[Elastic::Migration: 20201116142400] Skipping adding issues_access_level fields to issues documents migration since it is already applied')
        expect(Gitlab::Elastic::Helper.default.client).not_to receive(:search)

        expect(subject).to be_falsey
      end
    end

    context 'migration process' do
      before do
        allow(migration).to receive(:completed?).and_return(false)
      end

      let(:es_response_with_hits) do
        {
          'took': 0,
          'timed_out': false,
          '_shards': {
            'total': 5,
            'successful': 5,
            'skipped': 0,
            'failed': 0
          },
          'hits': {
            'total': {
              'value': 3,
              'relation': 'eq'
            },
            'max_score': nil,
            'hits': [
             {
               '_id': 'issue_1',
               '_source': {
                 'id': 1,
                 'join_field': {
                   'parent': 'project_1'
                 }
               }
             },
             {
               '_id': 'issue_2',
               '_source': {
                 'id': 2,
                 'join_field': {
                   'parent': 'project_1'
                 }
               }
             },
             {
               '_id': 'issue_3',
               '_source': {
                 'id': 3,
                 'join_field': {
                   'parent': 'project_2'
                 }
               }
             }
            ]
          }
        }
      end

      it 'updates all issue documents and logs a message', :aggregate_failures do
        expect(Gitlab::Elastic::Helper.default.client).to receive(:search).and_return(es_response_with_hits.with_indifferent_access)
        expect(Elastic::ProcessBookkeepingService).to receive(:track!).exactly(3).times
        expect(logger).to receive(:info).twice

        expect(subject).to be_truthy
      end
    end
  end

  describe '.completed?' do
    using RSpec::Parameterized::TableSyntax

    subject { migration.completed? }

    let(:es_response_doc_count) do
      {
        aggregations: {
          issues: {
            doc_count: doc_count
          }
        }
      }
    end

    where(:doc_count, :expected) do
      0 | true
      5 | false
    end

    with_them do
      it 'returns whether documents missing data are found' do
        expect(Gitlab::Elastic::Helper.default.client).to receive(:search).and_return(es_response_doc_count.with_indifferent_access)

        expect(subject).to eq(expected)
      end
    end
  end
end
