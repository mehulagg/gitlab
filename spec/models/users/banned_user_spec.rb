# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::BannedUser do
  it { is_expected.to belong_to(:user) }

  it 'validates uniqueness of banned user id' do
    subject.user = create(:user)
    is_expected.to validate_uniqueness_of(:user_id).with_message("banned user already exists")
  end
end
