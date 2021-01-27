# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoards::CreateService, services: true do
  def created_board
    service.execute.payload
  end

  let(:parent) { create(:group) }
  let(:epics_enabled) { false }
  let(:epic_boards_enabled) { false }

  before do
    stub_licensed_features(epics: epics_enabled)
    stub_feature_flags(epic_boards: epic_boards_enabled)
  end

  shared_examples 'does not create a board' do
    specify do
      service = described_class.new(parent, double)

      expect(service.execute.payload).not_to be_nil
      expect { service.execute }.not_to change(parent.epic_boards, :count)
    end
  end

  context 'With epics feature available' do
    let(:epics_enabled) { true }

    it_behaves_like 'does not create a board'

    context 'with epic boards feature available' do
      let(:epic_boards_enabled) { true }

      it_behaves_like 'create a board', :epic_boards
    end
  end

  context 'with epics feature not available' do
    it_behaves_like 'does not create a board'
  end
end
