# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicList do
  it_behaves_like 'boards listable model', :epic_list

  describe 'associations' do
    subject { build(:epic_list) }

    it { is_expected.to belong_to(:epic_board).required.inverse_of(:epic_lists) }
    it { is_expected.to belong_to(:label).inverse_of(:epic_lists) }
    it { is_expected.to validate_uniqueness_of(:label_id).scoped_to(:epic_board_id) }
  end
end
