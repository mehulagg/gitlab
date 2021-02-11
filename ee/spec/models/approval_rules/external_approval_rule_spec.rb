# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApprovalRules::ExternalApprovalRule, type: :model do
  subject { build(:external_approval_rule) }

  describe 'Associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_and_belong_to_many(:protected_branches) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:external_url) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id) }
    it { is_expected.to validate_uniqueness_of(:external_url).scoped_to(:project_id) }
  end
end
