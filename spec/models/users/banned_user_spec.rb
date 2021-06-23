# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::BannedUser do
  it { is_expected.to belong_to(:user) }

  it do
    subject.user = create(:user)
    is_expected.to validate_uniqueness_of(:user_id).with_message("banned user already exists")
  end

  context 'creates a new banned user' do
    it 'creates a new banned user object with is_banned ban state' do
      expect { described_class.new(user: user, ban_state: 3).save! }.to change { described_class.count }.by(1)
      expect(described_class.last.ban_state).to eq("is_banned")
    end
  end
end
