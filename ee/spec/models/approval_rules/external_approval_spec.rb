# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApprovalRules::ExternalApproval, type: :model do
  subject { build(:external_approval) }

  it { is_expected.to belong_to(:merge_request) }
  it { is_expected.to belong_to(:external_approval_rule) }
end
