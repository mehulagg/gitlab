# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequest::CleanupSchedule do
  describe 'associations' do
    it { is_expected.to belong_to(:merge_request) }
  end
end
