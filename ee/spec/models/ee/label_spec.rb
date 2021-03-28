# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Label do
  describe 'associations' do
    it { is_expected.to have_many(:epic_board_labels).inverse_of(:label) }
    it { is_expected.to have_many(:epic_lists).inverse_of(:label) }
  end

  describe 'scopes' do
    describe '.on_epic_board' do
      let(:group) { create(:group) }
      let(:board) { create(:epic_board, group: group) }
      let!(:list1) { create(:epic_list, epic_board: board, label: development) }
      let!(:list2) { create(:epic_list, epic_board: board, label: testing) }

      let!(:development) { create(:group_label, group: group, name: 'Development') }
      let!(:testing) { create(:group_label, group: group, name: 'Testing') }
      let!(:no_board_label) { create(:group_label, group: group, name: 'Feature') }

      it 'returns only the board labels' do
        expect(described_class.on_epic_board(board.id)).to match_array([development, testing])
      end
    end
  end

  describe '#scoped_label?' do
    context 'with scoped_labels available' do
      before do
        stub_licensed_features(scoped_labels: true)
      end

      it 'returns false for unscoped labels' do
        expect(build(:label, title: 'some name').scoped_label?).to be_falsey
      end

      it 'returns true for scoped labels' do
        expect(build(:label, title: 'key::some name').scoped_label?).to be_truthy
      end
    end
  end

  describe 'splitting scoped labels' do
    using RSpec::Parameterized::TableSyntax

    where(:title, :key, :value) do
      'key1::key 2::some value' | 'key1::key 2' | 'some value'
      'key1::some value'        | 'key1'        | 'some value'
      '::some value'            | ''            | 'some value'
      'some value'              | nil           | 'some value'
    end

    with_them do
      let(:label) { build(:label, title: title) }

      it '#scoped_label_key returns key for scoped labels' do
        expect(label.scoped_label_key).to eq(key)
      end

      it '#scoped_label_value returns title without the key' do
        expect(label.scoped_label_value).to eq(value)
      end
    end
  end
end
