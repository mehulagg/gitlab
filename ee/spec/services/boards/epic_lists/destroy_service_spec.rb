# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicLists::DestroyService do
  let_it_be(:group) { create(:group) }
  let_it_be_with_reload(:board) { create(:epic_board, group: group) }
  let_it_be(:label) { create(:group_label, group: group, name: 'in-progress') }
  let_it_be(:closed_list) { board.lists.create!(list_type: :closed) }

  let!(:list) { create(:epic_list, epic_board: board) }
  let(:user) { create(:user) }
  let(:parent) { group }
  let(:list_type) { :epic_list }
  let(:params) do
    { epic_board: board }
  end

  before do
    stub_licensed_features(epics: true)
  end

  context 'when user does not have permission' do
    it 'returns an error' do
      response = described_class.new(parent, nil).execute(list)

      expect(response).to be_error
      expect(response.errors).to include('The epic board list that you are attempting to destroy does not '\
                  'exist or you don\'t have permission to perform this action')
    end
  end

  context 'when user has permission' do
    before do
      group.add_maintainer(user)
    end

    it_behaves_like 'lists destroy service'

    context 'when epic feature is unavailable' do
      before do
        stub_licensed_features(epics: false)
      end

      it 'returns an error' do
        response = described_class.new(parent, nil).execute(list)

        expect(response).to be_error
        expect(response.errors).to include("Epics feature is not available.")
      end
    end
  end
end
