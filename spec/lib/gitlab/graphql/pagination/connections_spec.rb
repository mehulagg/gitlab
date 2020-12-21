# frozen_string_literal: true

require 'spec_helper'

# Tests that our connections are correctly mapped.
RSpec.describe ::Gitlab::Graphql::Pagination::Connections do
  include GraphqlHelpers

  before(:all) do
    ActiveRecord::Schema.define do
      create_table :testing_pagination_nodes, force: true do |t|
        t.integer :value, null: false
      end
    end
  end

  after(:all) do
    ActiveRecord::Schema.define do
      drop_table :testing_pagination_nodes, force: true
    end
  end

  let_it_be(:node_model) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'testing_pagination_nodes'
    end
  end

  let(:query_string) { 'query { items(first: 2) { nodes { value } } }' }
  let(:user) { nil }

  let(:node) { Struct.new(:value) }
  let(:node_type) do
    Class.new(::GraphQL::Schema::Object) do
      graphql_name 'Node'
      field :value, GraphQL::INT_TYPE, null: false
    end
  end

  let(:query_type) do
    item_values = nodes

    query_factory do |t|
      t.field :items, node_type.connection_type, null: true

      t.define_method :items do
        item_values
      end
    end
  end

  shared_examples 'it maps to a specific connection class' do |connection_type|
    it "maps to #{connection_type.name}" do
      expect(connection_type).to receive(:new).and_call_original

      results = execute_query(query_type).to_h

      expect(graphql_dig_at(results, :data, :items, :nodes, :value)).to eq [1, 7]
    end
  end

  describe 'OffsetPaginatedRelation' do
    before do
      node_model.create!(id: 1, value: 1)
      node_model.create!(id: 2, value: 7)
      node_model.create!(id: 3, value: 47)
    end

    let(:nodes) { ::Gitlab::Graphql::Pagination::OffsetPaginatedRelation.new(node_model.order(value: :asc)) }

    include_examples 'it maps to a specific connection class', Gitlab::Graphql::Pagination::OffsetActiveRecordRelationConnection
  end

  describe 'ActiveRecord::Relation' do
    before do
      node_model.create!(id: 3, value: 1)
      node_model.create!(id: 2, value: 7)
      node_model.create!(id: 1, value: 47)
    end

    let(:nodes) { node_model.all }

    include_examples 'it maps to a specific connection class', Gitlab::Graphql::Pagination::Keyset::Connection
  end

  describe 'ExternallyPaginatedArray' do
    let(:nodes) { ::Gitlab::Graphql::ExternallyPaginatedArray.new(nil, nil, node.new(1), node.new(7)) }

    include_examples 'it maps to a specific connection class', Gitlab::Graphql::Pagination::ExternallyPaginatedArrayConnection
  end

  describe 'Array' do
    let(:nodes) { [1, 7, 42].map { |x| node.new(x) } }

    include_examples 'it maps to a specific connection class', Gitlab::Graphql::Pagination::ArrayConnection
  end
end
