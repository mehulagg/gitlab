# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Pagination::Keyset::Order do
  let(:table) { Arel::Table.new(:my_table) }

  def run_query(query)
    ActiveRecord::Base.connection.execute(query).to_a
  end

  def build_query(order:, where_conditions: nil, limit: 999)
    where_conditions ||= '1=1'
    <<-SQL
    SELECT id, year, month
      FROM (#{table_data}) my_table (id, year, month) WHERE #{where_conditions} ORDER BY #{order} LIMIT #{limit};
    SQL
  end

  def iterate_and_collect(order:, page_size:, direction: :before, where_conditions: '1=1')
    all_items = []

    loop do
      paginated_items = run_query(build_query(order: order, where_conditions: where_conditions, limit: page_size))
      break if paginated_items.empty?

      all_items.concat(paginated_items)
      last_item = paginated_items.last
      cursor_attributes = order.cursor_attributes_for_node(last_item)
      where_conditions = order.build_conditions_recursively(order.column_definitions, cursor_attributes, direction).to_sql
    end

    all_items
  end

  shared_examples 'order examples' do
    it { expect(subject).to eq(expected) }

    context 'when paginating forwards' do
      subject { iterate_and_collect(order: order, page_size: 2) }

      it { expect(subject).to eq(expected) }

      context 'with different page size' do
        subject { iterate_and_collect(order: order, page_size: 5) }

        it { expect(subject).to eq(expected) }
      end
    end

    context 'when paginating backwards' do
      subject do
        last_item = expected.last
        cursor_attributes = order.cursor_attributes_for_node(last_item)
        where_conditions = order.build_conditions_recursively(order.column_definitions, cursor_attributes, :after)

        iterate_and_collect(order: order.reversed_order, page_size: 2, where_conditions: where_conditions.to_sql, direction: :after)
      end

      it do
        expect(subject).to eq(expected.reverse[1..-1]) # removing one item because we used it to calculate cursor data for the "last" page in subject
      end
    end
  end

  context 'when ordering by non-nullable columns' do
    let(:table_data) do
      <<-SQL
      VALUES (1,  2010, 2),
             (2,  2011, 1),
             (3,  2009, 2),
             (4,  2011, 1),
             (5,  2011, 1),
             (6,  2009, 2),
             (7,  2010, 3),
             (8,  2012, 4),
             (9,  2013, 5)
      SQL
    end

    let(:order) do
      Gitlab::Pagination::Keyset::Order.build([
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'year',
          column_expression: table['year'],
          order_expression: table['year'].asc,
          nullable: false,
          distinct: false
        ),
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'month',
          column_expression: table['month'],
          order_expression: table['month'].asc,
          nullable: false,
          distinct: false
        ),
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'id',
          column_expression: table['id'],
          order_expression: table['id'].asc,
          nullable: false,
          distinct: true
        )
      ])
    end

    let(:expected) do
      [
        { 'year' => 2009, 'month' => 2, 'id' => 3 },
        { 'year' => 2009, 'month' => 2, 'id' => 6 },
        { 'year' => 2010, 'month' => 2, 'id' => 1 },
        { 'year' => 2010, 'month' => 3, 'id' => 7 },
        { 'year' => 2011, 'month' => 1, 'id' => 2 },
        { 'year' => 2011, 'month' => 1, 'id' => 4 },
        { 'year' => 2011, 'month' => 1, 'id' => 5 },
        { 'year' => 2012, 'month' => 4, 'id' => 8 },
        { 'year' => 2013, 'month' => 5, 'id' => 9 }
      ]
    end

    subject do
      run_query(build_query(order: order))
    end

    it_behaves_like 'order examples'
  end

  context 'when ordering by some nullable columns with nulls last ordering' do
    let(:table_data) do
      <<-SQL
      VALUES (1,  2010, null),
             (2,  2011, 2),
             (3,  null, null),
             (4,  null, 5),
             (5,  2010, null),
             (6,  2011, 2),
             (7,  2010, 2),
             (8,  2012, 2),
             (9,  null, 2),
             (10, null, null),
             (11, 2010, 2)
      SQL
    end

    let(:order) do
      Gitlab::Pagination::Keyset::Order.build([
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'year',
          column_expression: table['year'],
          order_expression: Gitlab::Database.nulls_last_order('year', :asc),
          reversed_order_expression: Gitlab::Database.nulls_first_order('year', :desc),
          nullable: { nulls_position: :bottom },
          distinct: false
        ),
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'month',
          column_expression: table['month'],
          order_expression: Gitlab::Database.nulls_last_order('month', :asc),
          reversed_order_expression: Gitlab::Database.nulls_first_order('month', :desc),
          nullable: { nulls_position: :bottom },
          distinct: false
        ),
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'id',
          column_expression: table['id'],
          order_expression: table['id'].asc,
          nullable: false,
          distinct: true
        )
      ])
    end

    let(:expected) do
      [
        { "id" => 7, "year" => 2010, "month" => 2 },
        { "id" => 11, "year" => 2010, "month" => 2 },
        { "id" => 1, "year" => 2010, "month" => nil },
        { "id" => 5, "year" => 2010, "month" => nil },
        { "id" => 2, "year" => 2011, "month" => 2 },
        { "id" => 6, "year" => 2011, "month" => 2 },
        { "id" => 8, "year" => 2012, "month" => 2 },
        { "id" => 9, "year" => nil, "month" => 2 },
        { "id" => 4, "year" => nil, "month" => 5 },
        { "id" => 3, "year" => nil, "month" => nil },
        { "id" => 10, "year" => nil, "month" => nil }
      ]
    end

    subject { run_query(build_query(order: order)) }

    it_behaves_like 'order examples'
  end

  context 'when ordering by some nullable columns with nulls first ordering' do
    let(:table_data) do
      <<-SQL
      VALUES (1,  2010, null),
             (2,  2011, 2),
             (3,  null, null),
             (4,  null, 5),
             (5,  2010, null),
             (6,  2011, 2),
             (7,  2010, 2),
             (8,  2012, 2),
             (9,  null, 2),
             (10, null, null),
             (11, 2010, 2)
      SQL
    end

    let(:order) do
      Gitlab::Pagination::Keyset::Order.build([
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'year',
          column_expression: table['year'],
          order_expression: Gitlab::Database.nulls_first_order('year', :asc),
          reversed_order_expression: Gitlab::Database.nulls_last_order('year', :desc),
          nullable: { nulls_position: :top },
          distinct: false
        ),
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'month',
          column_expression: table['month'],
          order_expression: Gitlab::Database.nulls_first_order('month', :asc),
          reversed_order_expression: Gitlab::Database.nulls_last_order('month', :desc),
          nullable: { nulls_position: :top },
          distinct: false
        ),
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'id',
          column_expression: table['id'],
          order_expression: table['id'].asc,
          nullable: false,
          distinct: true
        )
      ])
    end

    let(:expected) do
      [
        { "id" => 3, "year" => nil, "month" => nil },
        { "id" => 10, "year" => nil, "month" => nil },
        { "id" => 9, "year" => nil, "month" => 2 },
        { "id" => 4, "year" => nil, "month" => 5 },
        { "id" => 1, "year" => 2010, "month" => nil },
        { "id" => 5, "year" => 2010, "month" => nil },
        { "id" => 7, "year" => 2010, "month" => 2 },
        { "id" => 11, "year" => 2010, "month" => 2 },
        { "id" => 2, "year" => 2011, "month" => 2 },
        { "id" => 6, "year" => 2011, "month" => 2 },
        { "id" => 8, "year" => 2012, "month" => 2 }
      ]
    end

    subject { run_query(build_query(order: order)) }

    it_behaves_like 'order examples'
  end
end
