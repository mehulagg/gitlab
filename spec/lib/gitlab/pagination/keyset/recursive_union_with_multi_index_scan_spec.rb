# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Pagination::Keyset::RecursiveUnionWithMultiIndexScan do
  let_it_be(:two_weeks_ago) { 2.weeks.ago }
  let_it_be(:three_weeks_ago) { 3.weeks.ago }
  let_it_be(:four_weeks_ago) { 4.weeks.ago }
  let_it_be(:five_weeks_ago) { 5.weeks.ago }

  let_it_be(:top_level_group) { create(:group) }
  let_it_be(:sub_group_1) { create(:group, parent: top_level_group) }
  let_it_be(:sub_group_2) { create(:group, parent: top_level_group) }
  let_it_be(:sub_sub_group_1) { create(:group, parent: sub_group_2) }

  let_it_be(:project_1) { create(:project, group: top_level_group) }
  let_it_be(:project_2) { create(:project, group: top_level_group) }

  let_it_be(:project_3) { create(:project, group: sub_group_1) }
  let_it_be(:project_4) { create(:project, group: sub_group_2) }

  let_it_be(:project_5) { create(:project, group: sub_sub_group_1) }

  let_it_be(:issues) do
    [
      create(:issue, project: project_1, created_at: three_weeks_ago),
      create(:issue, project: project_1, created_at: two_weeks_ago),
      create(:issue, project: project_2, created_at: two_weeks_ago),
      create(:issue, project: project_2, created_at: two_weeks_ago),
      create(:issue, project: project_3, created_at: four_weeks_ago),
      create(:issue, project: project_4, created_at: five_weeks_ago),
      create(:issue, project: project_5, created_at: four_weeks_ago)
    ]
  end

  shared_examples 'correct ordering examples' do
    let(:iterator) do
      Gitlab::Pagination::Keyset::Iterator.new(
        scope: scope.limit(batch_size),
        use_recursive_union_with_multi_index_scan: recursive_options
      )
    end

    it 'returns records in correct order' do
      all_records = []
      iterator.each_batch(of: batch_size) do |records|
        all_records.concat(records)
      end

      expect(all_records).to eq(expected_order)
    end
  end

  context 'when ordering by issues.id DESC' do
    let(:scope) { Issue.order(id: :desc) }
    let(:expected_order) { issues.sort_by(&:id).reverse }

    let(:recursive_options) do
      {
        array_scope: Project.where(namespace_id: top_level_group.self_and_descendants.select(:id)).select(:id),
        array_mapping_scope: -> (id_expression) { Issue.where(Issue.arel_table[:project_id].eq(id_expression)) },
        finder_query: -> (id_expression) { Issue.where(Issue.arel_table[:id].eq(id_expression)) }
      }
    end

    context 'when iterating records one by one' do
      let(:batch_size) { 1 }

      it_behaves_like 'correct ordering examples'
    end

    context 'when iterating records with LIMIT 3' do
      let(:batch_size) { 3 }

      it_behaves_like 'correct ordering examples'
    end

    context 'when loading records at once' do
      let(:batch_size) { issues.size + 1 }

      it_behaves_like 'correct ordering examples'
    end
  end

  context 'when ordering by issues.created_at DESC, issues.id ASC' do
    let(:scope) { Issue.order(created_at: :desc, id: :asc) }
    let(:expected_order) { issues.sort_by { |issue| [issue.created_at.to_f * -1, issue.id] } }

    let(:recursive_options) do
      {
        array_scope: Project.where(namespace_id: top_level_group.self_and_descendants.select(:id)).select(:id),
        array_mapping_scope: -> (id_expression) { Issue.where(Issue.arel_table[:project_id].eq(id_expression)) },
        finder_query: -> (_created_at_expression, id_expression) { Issue.where(Issue.arel_table[:id].eq(id_expression)) }
      }
    end

    context 'when iterating records one by one' do
      let(:batch_size) { 1 }

      it_behaves_like 'correct ordering examples'
    end

    context 'when iterating records with LIMIT 3' do
      let(:batch_size) { 3 }

      it_behaves_like 'correct ordering examples'
    end

    context 'when loading records at once' do
      let(:batch_size) { issues.size + 1 }

      it_behaves_like 'correct ordering examples'
    end
  end
end
