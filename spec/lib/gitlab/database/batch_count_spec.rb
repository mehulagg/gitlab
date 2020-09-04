# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::BatchCount do
  let_it_be(:fallback) { ::Gitlab::Database::BatchCounter::FALLBACK }
  let_it_be(:small_batch_size) { calculate_batch_size(::Gitlab::Database::BatchCounter::MIN_REQUIRED_BATCH_SIZE) }
  let(:model) { Issue }
  let(:column) { :author_id }

  let(:in_transaction) { false }
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  before do
    create_list(:issue, 3, author: user)
    create_list(:issue, 2, author: another_user)
    allow(ActiveRecord::Base.connection).to receive(:transaction_open?).and_return(in_transaction)
  end

  def calculate_batch_size(batch_size)
    zero_offset_modifier = -1

    batch_size + zero_offset_modifier
  end

  shared_examples 'disallowed configurations' do |method|
    it 'returns fallback if start is bigger than finish' do
      expect(described_class.public_send(method, *args, start: 1, finish: 0)).to eq(fallback)
    end

    it 'returns fallback if loops more than allowed' do
      large_finish = Gitlab::Database::BatchCounter::MAX_ALLOWED_LOOPS * default_batch_size + 1
      expect(described_class.public_send(method, *args, start: 1, finish: large_finish)).to eq(fallback)
    end

    it 'returns fallback if batch size is less than min required' do
      expect(described_class.public_send(method, *args, batch_size: small_batch_size)).to eq(fallback)
    end
  end

  shared_examples 'when a transaction is open' do
    let(:in_transaction) { true }

    it 'raises an error' do
      expect { subject }.to raise_error('BatchCount can not be run inside a transaction')
    end
  end

  shared_examples 'when batch fetch query is canceled' do
    let(:batch_size) { 22_000 }

    it 'reduces batch size by half and retry fetch' do
      relation = instance_double(ActiveRecord::Relation)
      to_big_batch_relation_mock = instance_double(ActiveRecord::Relation)
      allow(model).to receive_message_chain(:select, public_send: relation)
      allow(relation).to receive(:where).with("id" => 0..calculate_batch_size(batch_size)).and_return(to_big_batch_relation_mock)
      allow(to_big_batch_relation_mock).to receive(:send).and_raise(ActiveRecord::QueryCanceled)

      expect(relation).to receive(:where).with("id" => 0..calculate_batch_size(batch_size / 2)).and_return(double(send: 1))

      subject.call(model, column, batch_size: batch_size, start: 0)
    end

    context 'when all retries fail' do
      let(:batch_count_query) { 'SELECT COUNT(id) FROM relation WHERE id BETWEEN 0 and 1' }

      before do
        relation = instance_double(ActiveRecord::Relation)
        allow(model).to receive_message_chain(:select, :public_send, where: relation)
        allow(relation).to receive(:send).and_raise(ActiveRecord::QueryCanceled.new('query time outed'))
        allow(relation).to receive(:to_sql).and_return(batch_count_query)
      end

      context 'on gitlab.com' do
        before do
          allow(Gitlab).to receive(:com?).and_return(true)
        end

        it 'logs failing query' do
          expect(Gitlab::AppJsonLogger).to receive(:error).with(
            event: 'batch_count',
            relation: model.table_name,
            operation: operation,
            operation_args: operation_args,
            start: 0,
            mode: mode,
            query: batch_count_query,
            message: 'Query has been canceled with message: query time outed'
          )
          expect(subject.call(model, column, batch_size: batch_size, start: 0)).to eq(-1)
        end
      end

      context 'not on GitLab.com' do
        it 'does not log failing query' do
          expect(Gitlab::AppJsonLogger).not_to receive(:error)
          expect(subject.call(model, column, batch_size: batch_size, start: 0)).to eq(-1)
        end
      end
    end
  end

  describe '#batch_count' do
    it 'counts table' do
      expect(described_class.batch_count(model)).to eq(5)
    end

    it 'counts with :id field' do
      expect(described_class.batch_count(model, :id)).to eq(5)
    end

    it 'counts with "id" field' do
      expect(described_class.batch_count(model, 'id')).to eq(5)
    end

    it 'counts with table.id field' do
      expect(described_class.batch_count(model, "#{model.table_name}.id")).to eq(5)
    end

    it 'counts with Arel column' do
      expect(described_class.batch_count(model, model.arel_table[:id])).to eq(5)
    end

    it 'counts table with batch_size 50K' do
      expect(described_class.batch_count(model, batch_size: 50_000)).to eq(5)
    end

    it 'will not count table with a batch size less than allowed' do
      expect(described_class.batch_count(model, batch_size: small_batch_size)).to eq(fallback)
    end

    it 'counts with a small edge case batch_sizes than result' do
      stub_const('Gitlab::Database::BatchCounter::MIN_REQUIRED_BATCH_SIZE', 0)

      [1, 2, 4, 5, 6].each { |i| expect(described_class.batch_count(model, batch_size: i)).to eq(5) }
    end

    it 'counts with a start and finish' do
      expect(described_class.batch_count(model, start: model.minimum(:id), finish: model.maximum(:id))).to eq(5)
    end

    it "defaults the batch size to #{Gitlab::Database::BatchCounter::DEFAULT_BATCH_SIZE}" do
      min_id = model.minimum(:id)
      relation = instance_double(ActiveRecord::Relation)
      allow(model).to receive_message_chain(:select, public_send: relation)
      expected_batch_boundaries = min_id..(min_id + calculate_batch_size(Gitlab::Database::BatchCounter::DEFAULT_BATCH_SIZE))

      expect(relation).to receive(:where).with("id" => expected_batch_boundaries).and_return(double(send: 1))

      described_class.batch_count(model)
    end

    it_behaves_like 'when a transaction is open' do
      subject { described_class.batch_count(model) }
    end

    it_behaves_like 'when batch fetch query is canceled' do
      let(:mode) { :itself }
      let(:operation) { :count }
      let(:operation_args) { nil }
      let(:column) { nil }

      subject { described_class.method(:batch_count) }
    end

    context 'disallowed_configurations' do
      include_examples 'disallowed configurations', :batch_count do
        let(:args) { [Issue] }
        let(:default_batch_size) { Gitlab::Database::BatchCounter::DEFAULT_BATCH_SIZE }
      end

      it 'raises an error if distinct count is requested' do
        expect { described_class.batch_count(model.distinct(column)) }.to raise_error 'Use distinct count for optimized distinct counting'
      end
    end
  end

  describe '#batch_distinct_count' do
    it 'counts with column field' do
      expect(described_class.batch_distinct_count(model, column)).to eq(2)
    end

    it 'counts with "id" field' do
      expect(described_class.batch_distinct_count(model, "#{column}")).to eq(2)
    end

    it 'counts with table.column field' do
      expect(described_class.batch_distinct_count(model, "#{model.table_name}.#{column}")).to eq(2)
    end

    it 'counts with Arel column' do
      expect(described_class.batch_distinct_count(model, model.arel_table[column])).to eq(2)
    end

    it 'counts with :column field with batch_size of 50K' do
      expect(described_class.batch_distinct_count(model, column, batch_size: 50_000)).to eq(2)
    end

    it 'will not count table with a batch size less than allowed' do
      expect(described_class.batch_distinct_count(model, column, batch_size: small_batch_size)).to eq(fallback)
    end

    it 'counts with a small edge case batch_sizes than result' do
      stub_const('Gitlab::Database::BatchCounter::MIN_REQUIRED_BATCH_SIZE', 0)

      [1, 2, 4, 5, 6].each { |i| expect(described_class.batch_distinct_count(model, column, batch_size: i)).to eq(2) }
    end

    it 'counts with a start and finish' do
      expect(described_class.batch_distinct_count(model, column, start: model.minimum(column), finish: model.maximum(column))).to eq(2)
    end

    it 'counts with User min and max as start and finish' do
      expect(described_class.batch_distinct_count(model, column, start: User.minimum(:id), finish: User.maximum(:id))).to eq(2)
    end

    it "defaults the batch size to #{Gitlab::Database::BatchCounter::DEFAULT_DISTINCT_BATCH_SIZE}" do
      min_id = model.minimum(:id)
      relation = instance_double(ActiveRecord::Relation)
      allow(model).to receive_message_chain(:select, public_send: relation)
      expected_batch_boundaries = (min_id..min_id + calculate_batch_size(Gitlab::Database::BatchCounter::DEFAULT_DISTINCT_BATCH_SIZE))

      expect(relation).to receive(:where).with("id" => expected_batch_boundaries).and_return(double(send: 1))

      described_class.batch_distinct_count(model)
    end

    it_behaves_like 'when a transaction is open' do
      subject { described_class.batch_distinct_count(model, column) }
    end

    context 'disallowed configurations' do
      include_examples 'disallowed configurations', :batch_distinct_count do
        let(:args) { [model, column] }
        let(:default_batch_size) { Gitlab::Database::BatchCounter::DEFAULT_DISTINCT_BATCH_SIZE }
      end

      it 'will raise an error if distinct count with the :id column is requested' do
        expect do
          described_class.batch_count(described_class.batch_distinct_count(model, :id))
        end.to raise_error 'Use distinct count only with non id fields'
      end
    end

    it_behaves_like 'when batch fetch query is canceled' do
      let(:mode) { :distinct }
      let(:operation) { :count }
      let(:operation_args) { nil }
      let(:column) { nil }

      subject { described_class.method(:batch_distinct_count) }
    end
  end

  describe '#batch_sum' do
    let(:column) { :weight }

    before do
      Issue.first.update_attribute(column, 3)
      Issue.last.update_attribute(column, 4)
    end

    it 'returns the sum of values in the given column' do
      expect(described_class.batch_sum(model, column)).to eq(7)
    end

    it 'works when given an Arel column' do
      expect(described_class.batch_sum(model, model.arel_table[column])).to eq(7)
    end

    it 'works with a batch size of 50K' do
      expect(described_class.batch_sum(model, column, batch_size: 50_000)).to eq(7)
    end

    it 'works with start and finish provided' do
      expect(described_class.batch_sum(model, column, start: model.minimum(:id), finish: model.maximum(:id))).to eq(7)
    end

    it 'returns the same result regardless of batch size' do
      stub_const('Gitlab::Database::BatchCounter::DEFAULT_SUM_BATCH_SIZE', 0)

      (1..(model.count + 1)).each { |i| expect(described_class.batch_sum(model, column, batch_size: i)).to eq(7) }
    end

    it "defaults the batch size to #{Gitlab::Database::BatchCounter::DEFAULT_SUM_BATCH_SIZE}" do
      min_id = model.minimum(:id)
      relation = instance_double(ActiveRecord::Relation)
      allow(model).to receive_message_chain(:select, public_send: relation)
      expected_batch_boundaries = (min_id..min_id + calculate_batch_size(Gitlab::Database::BatchCounter::DEFAULT_SUM_BATCH_SIZE))

      expect(relation).to receive(:where).with("id" => expected_batch_boundaries).and_return(double(send: 1))

      described_class.batch_sum(model, column)
    end

    it_behaves_like 'when a transaction is open' do
      subject { described_class.batch_sum(model, column) }
    end

    it_behaves_like 'disallowed configurations', :batch_sum do
      let(:args) { [model, column] }
      let(:default_batch_size) { Gitlab::Database::BatchCounter::DEFAULT_SUM_BATCH_SIZE }
      let(:small_batch_size) { Gitlab::Database::BatchCounter::DEFAULT_SUM_BATCH_SIZE - 1 }
    end

    it_behaves_like 'when batch fetch query is canceled' do
      let(:mode) { :itself }
      let(:operation) { :sum }
      let(:operation_args) { [column] }

      subject { described_class.method(:batch_sum) }
    end
  end
end
