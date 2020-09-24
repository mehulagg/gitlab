# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicUserPreference do
  subject { build(:epic_user_preference) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:board) }
    it { is_expected.to belong_to(:epic) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:user).scoped_to([:board_id, :epic_id]) }
  end
end
