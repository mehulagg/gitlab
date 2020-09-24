# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BoardUserPreference do
  before do
    create(:board_user_preference)
  end

  describe 'relationships' do
    it { is_expected.to belong_to(:board) }
    it { is_expected.to belong_to(:user) }

    it do
      is_expected.to validate_uniqueness_of(:user_id).scoped_to(:board_id)
                       .with_message("should have only one board preference per user")
    end
  end
end
