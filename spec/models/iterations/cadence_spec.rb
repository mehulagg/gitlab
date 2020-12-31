# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Iterations::Cadence do
  describe 'associations' do
    subject { build(:iteration_cadence) }

    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_many(:iterations) }
  end

  describe 'validations' do
    subject { build(:iteration_cadence) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:group_id) }
  end
end
