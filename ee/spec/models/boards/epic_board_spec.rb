# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoard do
  describe 'associations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_many(:epic_board_labels) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:group) }
  end
end
