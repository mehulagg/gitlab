# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequestApprovalSetting do
  describe 'Associations' do
    it { is_expected.to belong_to :namespace }
  end

  describe 'Validations' do
    let_it_be(:setting) { create(:merge_request_approval_setting) }

    subject { setting }

    it { is_expected.not_to allow_value(nil).for(:allow_author_approval) }
    it { is_expected.to allow_value(true, false).for(:allow_author_approval) }
  end
end
