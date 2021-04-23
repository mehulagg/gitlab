# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Pagination::Keyset::Iterator do
  let_it_be(:project) { create(:project) }
  let_it_be(:issue_list_with_same_pos) { create_list(:issue, 3, project: project, relative_position: 100, updated_at: 1.day.ago) }
  let_it_be(:issue_list_with_null_pos) { create_list(:issue, 3, project: project, relative_position: nil, updated_at: 1.day.ago) }
  let_it_be(:issue_list_with_asc_pos) { create_list(:issue, 3, :with_asc_relative_position, project: project, updated_at: 1.day.ago) }

  let(:klass) { Issue }
  let(:column_name) { 'relative_position' }
  let(:direction) { :asc }
  let(:reverse_direction) { :desc }
  let(:desc) { :desc }
  let(:custom_reorder) do
    Gitlab::Pagination::Keyset::Order.build([
      Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
        attribute_name: "#{column_name}",
        column_expression: klass.arel_table[column_name],
        order_expression: Gitlab::Database.nulls_last_order(column_name, direction),
        reversed_order_expression: Gitlab::Database.nulls_first_order(column_name, reverse_direction),
        order_direction: direction,
        nullable: :nulls_last,
        distinct: false
      ),
      Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
        attribute_name: 'id',
        order_expression: klass.arel_table[:id].send(direction),
        add_to_projections: true
      )
    ])
  end

  let(:scope) { project.issues }

  subject { described_class.new(scope: scope.order(custom_reorder)) }

  describe '.each_batch' do
    it 'yields an ActiveRecord::Relation when a block is given' do
      subject.each_batch(of: 1) do |relation|
        expect(relation).to be_a_kind_of(ActiveRecord::Relation)
      end
    end

    it 'accepts a custom batch size' do
      amount = 0

      subject.each_batch(of: 2 ) { amount += 1 }
      expect(amount).to eq(5)
    end

    it 'allows updating of the yielded relations' do
      time = Time.current

      subject.each_batch(of: 2) do |relation|
        relation.update_all(updated_at: time)
      end

      expect(Issue.where(updated_at: time).count).to eq(9)
    end

    context 'with ordering direction' do
      context 'when ordering asc' do
        it 'orders ascending by default' do
          positions = []

          subject.each_batch(of: 2) { |rel| positions.concat(rel.pluck(:relative_position)) }

          expect(positions).to eq(project.issues.order_relative_position_asc.pluck(:relative_position))
        end
      end

      context 'when ordering desc' do
        let(:direction) { :desc }
        let(:reverse_direction) { :asc }

        it 'accepts descending order' do
          positions = []

          subject.each_batch(of: 2) { |rel| positions.concat(rel.pluck(:relative_position)) }

          expect(positions).to eq(project.issues.order_relative_position_desc.pluck(:relative_position))
        end
      end
    end
  end
end
