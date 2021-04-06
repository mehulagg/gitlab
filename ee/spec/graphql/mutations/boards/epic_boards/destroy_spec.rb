# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Mutations::Boards::EpicBoards::Destroy do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be_with_reload(:board) { create(:epic_board, group: group) }
  let_it_be(:another_board) { create(:epic_board, group: group) }

  let(:mutation) { described_class.new(object: nil, context: { current_user: current_user }, field: nil) }

  subject { mutation.resolve(id: board.to_global_id) }

  context 'field tests' do
    subject { described_class }

    it { is_expected.to have_graphql_arguments(:id) }
    it { is_expected.to have_graphql_fields(:epic_board).at_least }
  end

  before do
    stub_licensed_features(epics: true)
  end

  it 'raises error when user does not have permission to destroy the board' do
    expect { subject }
      .to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
  end

  context 'when user has permission to destroy the board' do
    before do
      group.add_reporter(current_user)
    end

    it 'destroys the epic board' do
      result = mutation.resolve(id: board.to_global_id)

      expect(result[:errors]).to be_empty
      expect(result[:epic_board]).to be_nil
    end
  end
end
