# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoardLabel do
  describe 'associations' do
    it { is_expected.to belong_to(:epic_board) }
    it { is_expected.to belong_to(:label) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:epic_board) }
    it { is_expected.to validate_presence_of(:label) }
  end
end
