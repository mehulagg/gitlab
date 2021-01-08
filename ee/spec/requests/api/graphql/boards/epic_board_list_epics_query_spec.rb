# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'get list of epics for an epic  board list' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:development) { create(:group_label, group: group, name: 'Development') }
  let_it_be(:board) { create(:epic_board, group: group) }
  let_it_be(:list) { create(:epic_list, epic_board: board, label: development) }

  let_it_be(:epic1) { create(:labeled_epic, group: group, labels: [development]) }
  let_it_be(:epic2) { create(:labeled_epic, group: group, labels: [development]) }
  let_it_be(:epic3) { create(:labeled_epic, group: group, labels: [development]) }
  let_it_be(:epic4) { create(:labeled_epic, group: group) }

  let_it_be(:epic_pos1) { create(:epic_board_position, epic: epic1, epic_board: board, relative_position: 20) }
  let_it_be(:epic_pos2) { create(:epic_board_position, epic: epic2, epic_board: board, relative_position: 10) }

  def pagination_query(params = {})
    graphql_query_for(:group, { full_path: group.full_path },
      <<~BOARDS
        epicBoard(id: "#{board.to_global_id}") {
          lists(id: "#{list.to_global_id}") {
            nodes {
              #{query_nodes(:epics, all_graphql_fields_for('epics'.classify), include_pagination_info: true, args: params)}
            }
          }
        }
      BOARDS
    )
  end

  before do
    stub_licensed_features(epics: true)
    group.add_developer(current_user)
  end

  describe 'sorting and pagination' do
    let(:data_path) { [:group, :epicBoard, :lists, :nodes, 0, :epics] }
    let(:expected_results) { [epic2.to_global_id.to_s, epic1.to_global_id.to_s, epic3.to_global_id.to_s] }

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
