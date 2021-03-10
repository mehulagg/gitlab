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
    it { is_expected.not_to allow_value(nil).for(:allow_committer_approval) }
    it { is_expected.to allow_value(true, false).for(:allow_committer_approval) }
    it { is_expected.not_to allow_value(nil).for(:allow_overrides_to_approver_list_per_merge_request) }
    it { is_expected.to allow_value(true, false).for(:allow_overrides_to_approver_list_per_merge_request) }
    it { is_expected.not_to allow_value(nil).for(:retain_approvals_on_push) }
    it { is_expected.to allow_value(true, false).for(:retain_approvals_on_push) }
    it { is_expected.not_to allow_value(nil).for(:require_password_to_approve) }
    it { is_expected.to allow_value(true, false).for(:require_password_to_approve) }
  end

  describe '.find_or_initialize_by_group' do
    let_it_be(:group) { create(:group) }

    subject { described_class.find_or_initialize_by_group(group) }

    context 'with no existing setting' do
      it { is_expected.to be_a_new_record }
    end

    context 'with existing setting' do
      let_it_be(:setting) { create(:group_merge_request_approval_setting, group: group) }

      it { is_expected.to eq(setting) }
    end
  end
end
