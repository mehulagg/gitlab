# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventPolicy do
  let(:user) { create(:user) }
  let(:event) { create(:event, :created, target: create(:epic, group: group)) }

  subject { described_class.new(user, event) }

  before do
    stub_licensed_features(epics: true)
  end

  context 'when the user cannot read the epic' do
    let(:group) { create(:group, :private) }

    it { expect_disallowed(:read_event) }
  end

  context 'when the user can read the epic' do
    let(:group) { create(:group, :public) }

    it { expect_allowed(:read_event) }
  end
end
