# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicList do
  describe 'associations' do
    it { is_expected.to belong_to(:epic_board).required.inverse_of(:epic_lists) }
    it { is_expected.to belong_to(:label).required.inverse_of(:epic_lists) }
    it { is_expected.to validate_presence_of(:position) }
  end
end
