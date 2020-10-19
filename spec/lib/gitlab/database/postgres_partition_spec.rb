# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::PostgresPartition, type: :model do
  let(:schema) { 'gitlab_partitions_dynamic' }
  let(:name) { 'foo_range_01' }
  let(:identifier) { "#{schema}.#{name}" }

  before do
    ActiveRecord::Base.connection.execute(<<~SQL)
      CREATE TABLE public.foo_range (
        id serial NOT NULL,
        created_at timestamptz NOT NULL,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE(created_at);

      CREATE TABLE #{identifier} PARTITION OF public.foo_range
      FOR VALUES FROM ('2020-01-01') to ('2020-02-01');
    SQL
  end

  def find(identifier)
    described_class.by_identifier(identifier)
  end

  describe 'associations' do
    it { is_expected.to belong_to(:postgres_partitioned_table).with_primary_key('identifier').with_foreign_key('parent_identifier') }
  end

  it_behaves_like 'a postgres model'

  describe '#parent_identifier' do
    it 'returns the parent table identifier' do
      expect(find(identifier).parent_identifier).to eq('public.foo_range')
    end
  end

  describe '#condition' do
    it 'returns the condition for the partitioned values' do
      expect(find(identifier).condition).to eq("FOR VALUES FROM ('2020-01-01 00:00:00+00') TO ('2020-02-01 00:00:00+00')")
    end
  end
end
