# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::UpdateEpicUserPreferences do
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:project) { create(:project, :private) }
  let_it_be(:user) { create(:user) }
  let_it_be(:board) { create(:board, project: project) }
  let_it_be(:epic) { create(:epic, group: group) }

  let(:context) { { current_user: user } }

  subject(:mutation) { described_class.new(object: nil, context: context, field: nil).resolve(**mutation_params) }

  describe '#resolve' do
    before do
      stub_licensed_features(epics: true)
    end

    let(:mutation_params) do
      {
        board_id: board.to_global_id,
        epic_id: epic.to_global_id,
        collapsed: true
      }
    end

    it 'returns an error if the board is not accessible by the user' do
      expect { mutation }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when user can access the board' do
      before do
        project.add_developer(user)
      end

      it 'returns an error if the epic is not accessible by the user' do
        expect { mutation }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end

      context 'when user can access the epic' do
        before do
          group.add_developer(user)
        end

        it 'returns updated preferences' do
          expect(mutation[:errors]).to be_empty
          expect(mutation[:epic_user_preferences].collapsed).to be_truthy
        end
      end
    end
  end
end
