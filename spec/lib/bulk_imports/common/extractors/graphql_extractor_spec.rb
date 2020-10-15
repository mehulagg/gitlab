# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Common::Extractors::GraphqlExtractor do
  let(:graphql_client) { instance_double(BulkImports::Clients::Graphql) }
  let(:import_entity) { create(:bulk_import_entity) }
  let(:response) { double(original_hash: { foo: :bar }) }
  let(:query) { 'test' }
  let(:context) do
    instance_double(
      BulkImports::Pipeline::Context,
      entities: [import_entity]
    )
  end

  before do
    allow(subject).to receive(:graphql_client).and_return(graphql_client)
    allow(graphql_client).to receive(:parse)
  end

  describe '#extract' do
    before do
      allow(subject).to receive(:query_variables).and_return({})
      allow(graphql_client).to receive(:execute).and_return(response)
    end

    subject { described_class.new({ query: query, variables: {} }) }

    it 'returns an enumerator with fetched results' do
      response = subject.extract(context)

      expect(response).to be_instance_of(Enumerator)
      expect(response.first).to eq({ foo: :bar })
    end
  end

  describe 'query variables' do
    before do
      allow(graphql_client).to receive(:execute).and_return(response)
    end

    subject { described_class.new({ query: query, variables: { full_path: :source_full_path } }) }

    it 'builds graphql query variables for import entity' do
      expected_variables = { full_path: import_entity.source_full_path }

      expect(graphql_client).to receive(:execute).with(anything, expected_variables)

      subject.extract(context).first
    end

    context 'when no variables are present' do
      subject { described_class.new({ query: query }) }

      it 'returns empty hash' do
        expect(graphql_client).to receive(:execute).with(anything, nil)

        subject.extract(context).first
      end
    end

    context 'when variables are empty hash' do
      subject { described_class.new({ query: query, variables: {} }) }

      it 'makes graphql request with empty hash' do
        expect(graphql_client).to receive(:execute).with(anything, {})

        subject.extract(context).first
      end
    end
  end
end
