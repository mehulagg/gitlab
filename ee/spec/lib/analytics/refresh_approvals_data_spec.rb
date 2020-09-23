# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::RefreshApprovalsData do
  subject { described_class.new(merge_request) }

  let(:merge_request) { create :merge_request }

  describe '#execute' do
    let(:calculated_value) { 2.days.ago.beginning_of_day }

    include_examples 'common merge request metric refresh for', :first_approved_at
  end
end
