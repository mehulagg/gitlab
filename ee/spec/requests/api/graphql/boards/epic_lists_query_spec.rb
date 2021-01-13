# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'get list of epic boards' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:board) { create(:epic_board, group: group) }
  let_it_be(:list1) { create(:epic_list, epic_board: board) }
  let_it_be(:list2) { create(:epic_list, epic_board: board, list_type: :closed) }
  let_it_be(:list3) { create(:epic_list, epic_board: board, list_type: :backlog) }

  def pagination_query(params = {})
    graphql_query_for(:group, { full_path: group.full_path },
      <<~BOARDS
        epicBoard(id: "#{board.to_global_id}") {
          #{query_nodes(:lists, all_graphql_fields_for('epic_lists'.classify), include_pagination_info: true, args: params)}
        }
      BOARDS
    )
  end

  before do
    stub_licensed_features(epics: true)
  end

  context 'when the user does not have access to the epic board group' do
    it 'returns nil group' do
      post_graphql(pagination_query, current_user: current_user)

      expect(graphql_data['group']).to be_nil
    end
  end

  context 'when user can access the epic board group' do
    before do
      group.add_developer(current_user)
    end

    describe 'sorting and pagination' do
      let(:data_path) { [:group, :epicBoard, :lists] }
      let(:expected_results) { [list3.to_global_id.to_s, list1.to_global_id.to_s, list2.to_global_id.to_s] }

      def pagination_results_data(nodes)
        nodes.map { |list| list['id'] }
      end

      it_behaves_like 'sorted paginated query' do
        # currently we don't support custom sorting for epic lists,
        # nil value will be ignored by ::Graphql::Arguments
        let(:sort_param) { nil }
        let(:first_param) { 2 }
      end
    end
  end
end
