# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicList do
  it_behaves_like 'boards listable model', :epic_list
  it_behaves_like 'list_preferences_for user', :epic_list, :epic_list_id

  describe 'associations' do
    subject { build(:epic_list) }

    it { is_expected.to belong_to(:epic_board).required.inverse_of(:epic_lists) }
    it { is_expected.to belong_to(:label).inverse_of(:epic_lists) }
    it { is_expected.to have_many(:epic_list_user_preferences).inverse_of(:epic_list) }
    it { is_expected.to validate_uniqueness_of(:label_id).scoped_to(:epic_board_id) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:label) }
  end
end
