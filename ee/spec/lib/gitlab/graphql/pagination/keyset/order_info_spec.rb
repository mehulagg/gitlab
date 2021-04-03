# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Graphql::Pagination::Keyset::OrderInfo do
  describe '#build_order_list' do
    let(:order_list) { described_class.build_order_list(relation) }

    context 'when ordering by STORAGE' do
      let(:relation) { Project.order_by_total_repository_size_excess_desc(10.gigabytes) }

      it 'assigns the right attribute name, named function, and direction' do
        expect(order_list.count).to eq 1
        expect(order_list.first.attribute_name).to eq 'excess_storage'
        expect(order_list.first.named_function).to be_kind_of(Arel::Nodes::Grouping)
        expect(order_list.first.named_function.to_sql.delete('"')).to include '(project_statistics.repository_size + project_statistics.lfs_objects_size)'
        expect(order_list.first.sort_direction).to eq :desc
      end
    end
  end
end
