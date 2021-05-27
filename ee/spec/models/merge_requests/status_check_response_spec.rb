# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::StatusCheckResponse, type: :model do
  subject { build(:status_check_response) }

  it { is_expected.to belong_to(:merge_request) }
  it { is_expected.to belong_to(:external_approval_rule).class_name('ApprovalRules::ExternalApprovalRule') }

  it { is_expected.to validate_presence_of(:merge_request) }
  it { is_expected.to validate_presence_of(:external_approval_rule) }
  it { is_expected.to validate_presence_of(:sha) }
end
