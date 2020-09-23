# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AwardEmojiPolicy do
  let(:user) { create(:user) }
  let(:award_emoji) { create(:award_emoji, awardable: create(:epic, group: group)) }

  subject { described_class.new(user, award_emoji) }

  before do
    stub_licensed_features(epics: true)
  end

  context 'when the user cannot read the epic' do
    let(:group) { create(:group, :private) }

    it { expect_disallowed(:read_emoji) }
  end

  context 'when the user can read the epic' do
    let(:group) { create(:group, :public) }

    it { expect_allowed(:read_emoji) }
  end
end
