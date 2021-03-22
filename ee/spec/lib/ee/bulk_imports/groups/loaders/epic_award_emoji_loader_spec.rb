# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Loaders::EpicAwardEmojiLoader do
  describe '#load' do
    let_it_be(:user) { create(:user) }
    let_it_be(:group) { create(:group) }
    let_it_be(:epic) { create(:epic, group: group, iid: 1) }
    let_it_be(:bulk_import) { create(:bulk_import, user: user) }
    let_it_be(:entity) { create(:bulk_import_entity, bulk_import: bulk_import, group: group) }
    let_it_be(:tracker) { create(:bulk_import_tracker, entity: entity) }
    let_it_be(:context) { BulkImports::Pipeline::Context.new(tracker) }

    let_it_be(:data) do
      {
        'name' => 'banana',
        'user_id' => user.id
      }
    end

    before do
      stub_licensed_features(epics: true)
      context.extra[:epic_iid] = epic.iid
      group.add_developer(user)
    end

    context 'when emoji does not exist' do
      it 'creates new emoji' do
        expect { subject.load(context, data) }.to change(::AwardEmoji, :count).by(1)

        epic = group.epics.last
        emoji = epic.award_emoji.first

        expect(emoji.name).to eq(data['name'])
        expect(emoji.user).to eq(user)
      end
    end

    context 'when same emoji exists' do
      it 'does not create a new emoji' do
        epic.award_emoji.create!(data)

        expect { subject.load(context, data) }.not_to change(::AwardEmoji, :count)
      end
    end

    context 'when user is not allowed to award emoji' do
      before do
        allow(Ability).to receive(:allowed?).with(user, :award_emoji, epic).and_return(false)
      end

      it 'raises NotAllowedError exception' do
        expect { subject.load(context, data) }.to raise_error(described_class::NotAllowedError)
      end
    end
  end
end
