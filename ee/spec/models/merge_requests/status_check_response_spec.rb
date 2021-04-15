# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::StatusCheckResponse, type: :model do
  subject { build(:status_check_response) }

  it { is_expected.to belong_to(:merge_request) }
  it { is_expected.to belong_to(:external_approval_rule) }
end
