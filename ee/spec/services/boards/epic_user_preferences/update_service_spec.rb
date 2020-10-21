# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicUserPreferences::UpdateService, services: true do
  describe '#execute' do
    let_it_be(:group) { create(:group) }
    let_it_be(:user) { create(:user) }
    let_it_be(:board) { create(:board) }
    let_it_be(:epic) { create(:epic, group: group) }

    subject(:service) { described_class.new(user, board, epic, { collapsed: true }).execute }

    it 'creates new preference' do
      expect { service }.to change { Boards::EpicUserPreference.count }.by(1)

      expect(service[:status]).to be_truthy
      expect(service[:epic_user_preferences].collapsed).to be_truthy
    end

    context 'when user preference already exists' do
      let_it_be(:epic_user_preference, reload: true) { create(:epic_user_preference, board: board, epic: epic, user: user) }

      it 'updates existing preference' do
        expect { service }.not_to change { Boards::EpicUserPreference.count }

        expect(service[:status]).to be_truthy
        expect(service[:epic_user_preferences].collapsed).to be_truthy
      end
    end

    context 'when user is not set' do
      let(:user) { nil }

      it 'returns an error' do
        expect(service[:status]).to eq(:error)
        expect(service[:message]).to eq('User not set')
      end
    end
  end
end
