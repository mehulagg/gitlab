# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NotesFinder do
  let(:group) { create(:group) }
  let(:user) { create(:group_member, :owner, group: group, user: create(:user)).user }
  let(:epic) { create(:epic, :opened, author: user, group: group) }
  let!(:note) { create(:note_on_epic, noteable: epic) }

  before do
    stub_licensed_features(epics: true)
  end

  describe '#target' do
    subject { described_class.new(user, { target_id: epic.id, target_type: 'epic', group_id: group.id }).target }

    it 'returns an epic' do
      expect(subject).to eq(epic)
    end

    it 'fails if group id is missing' do
      expect {  described_class.new(user, { target_id: epic.id, target_type: 'epic' }).target }.to raise_error(ArgumentError)
    end
  end

  describe '#execute' do
    context 'when using target id and type of epics' do
      subject { described_class.new(user, { target_id: epic.id, target_type: 'epic', group_id: group.id }).execute }

      it 'returns the expected notes' do
        expect(subject).to eq([note])
      end

      it 'fails if group id is missing' do
        expect { described_class.new(user, { target_id: epic.id, target_type: 'epic' }).execute }.to raise_error(ArgumentError)
      end
    end

    context 'when using an explicit epic target' do
      subject { described_class.new(user, { target: epic }).execute }

      it 'returns the expected notes' do
        expect(subject).to eq([note])
      end
    end
  end
end
