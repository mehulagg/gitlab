# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicList do
  describe 'associations' do
    subject { build(:epic_list) }

    it { is_expected.to belong_to(:epic_board).required.inverse_of(:epic_lists) }
    it { is_expected.to belong_to(:label).inverse_of(:epic_lists) }
    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_uniqueness_of(:label_id).scoped_to(:epic_board_id) }

    context 'when list_type is set to closed' do
      subject { build(:epic_list, list_type: :closed) }

      it { is_expected.not_to validate_presence_of(:label) }
      it { is_expected.not_to validate_presence_of(:position) }
    end
  end

  describe 'scopes' do
    describe '.ordered' do
      it 'returns lists ordered by type and position' do
        list1 = create(:epic_list, list_type: :backlog)
        list2 = create(:epic_list, list_type: :closed)
        list3 = create(:epic_list, position: 1)
        list4 = create(:epic_list, position: 2)

        expect(described_class.ordered).to eq([list1, list3, list4, list2])
      end
    end
  end

  describe '#title' do
    it 'returns label name for label lists' do
      list = build(:epic_list)
      expect(list.title).to eq(list.label.name)
    end

    it 'returns list type for non-label lists' do
      expect(build(:epic_list, list_type: ::Boards::EpicList.list_types[:backlog]).title).to eq('Backlog')
    end
  end
end
