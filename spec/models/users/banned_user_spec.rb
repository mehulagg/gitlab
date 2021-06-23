# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::BannedUser do
  it { is_expected.to belong_to(:user) }

  it do
    is_expected.to validate_uniqueness_of(:user_id)
                     .with_message("banned user already exists")
  end
end
