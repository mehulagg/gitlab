# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserRecentEventsFinder do
  describe '#execute' do
    let_it_be(:current_user) { create(:user) }
    let_it_be(:user) { create(:user) }
    let_it_be(:epic) { create(:epic) }
    let_it_be(:private_epic) { create(:epic, group: create(:group, :private)) }
    let_it_be(:note) { create(:note_on_epic, noteable: epic) }
    let_it_be(:event_a) { create(:event, :commented, target: note, author: user, project: nil) }
    let_it_be(:event_b) { create(:event, :closed, target: epic, author: user, project: nil) }
    let_it_be(:private_event) { create(:event, :closed, target: private_epic, author: user, project: nil) }

    subject(:finder) { described_class.new(current_user, user, {}) }

    context 'epic reelated activities' do
      context 'when profile is public' do
        it 'returns all the events' do
          expect(finder.execute).to match_array([event_a, event_b, private_event])
        end
      end

      context 'when profile is private' do
        it 'does not return any events' do
          allow(Ability).to receive(:allowed?).and_call_original
          allow(Ability).to receive(:allowed?).with(current_user, :read_user_profile, user).and_return(false)

          expect(finder.execute).to be_empty
        end
      end
    end
  end
end
