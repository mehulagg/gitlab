# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupMergeRequestApprovalSetting do
  describe 'Associations' do
    it { is_expected.to belong_to :group }
  end

  describe 'Validations' do
    let_it_be(:setting) { create(:group_merge_request_approval_setting) }

    subject { setting }

    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.not_to allow_value(nil).for(:allow_author_approval) }
    it { is_expected.to allow_value(true, false).for(:allow_author_approval) }
  end
end
