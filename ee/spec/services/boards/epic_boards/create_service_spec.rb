# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoards::CreateService, services: true do
  def created_board
    service.execute.payload
  end

  let_it_be(:user) { create(:user) }

  let(:parent) { create(:group) }
  let(:epic_boards_enabled) { false }

  before do
    stub_feature_flags(epic_boards: epic_boards_enabled)
  end

  context 'with epic boards feature not available' do
    it 'does not create a board' do
      service = described_class.new(parent, user)

      expect(service.execute.payload).not_to be_nil
      expect { service.execute }.not_to change(parent.epic_boards, :count)
    end
  end

  context 'with epic boards feature available' do
    let(:epic_boards_enabled) { true }

    it_behaves_like 'create a board', :epic_boards

    it 'tracks epic board creation' do
      expect(Gitlab::UsageDataCounters::HLLRedisCounter)
        .to receive(:track_event).with('g_project_management_users_creating_epic_boards', values: user.id)

      described_class.new(parent, user).execute
    end
  end
end
