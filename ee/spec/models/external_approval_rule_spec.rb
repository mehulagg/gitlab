# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExternalApprovalRule, type: :model do
  subject { described_class.new }

  describe 'Associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_and_belong_to_many(:protected_branches) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:external_url) }
  end
end
