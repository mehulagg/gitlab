# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'get list of epic boards' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:board1) { create(:epic_board, group: group, name: 'B') }
  let_it_be(:board2) { create(:epic_board, group: group, name: 'A') }

  let(:fields) do
    <<~GQL
      nodes {
        #{all_graphql_fields_for('epic_boards'.classify)}
      }
    GQL
  end

  let(:query) do
    graphql_query_for(
      'group',
      { 'fullPath' => group.full_path },
      query_graphql_field('epicBoards', {}, fields)
    )
  end

  before do
    stub_licensed_features(epics: true)
  end

  context 'when the user does not have access to the epic board group' do
    it 'returns nil' do
      post_graphql(query)

      expect(graphql_data['group']).to be_nil
    end
  end

  context 'when user can access the epic board group' do
    before do
      group.add_developer(current_user)
    end

    it 'returns epic boards in the group' do
      post_graphql(query, current_user: current_user)

      boards = graphql_data.dig('group', 'epicBoards', 'nodes')
      expect(boards.map { |b| b['id'] }).to eq([board2.to_global_id.to_s, board1.to_global_id.to_s])
    end
  end
end
