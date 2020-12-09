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

  describe '.find_or_initialize_by_namespace' do
    let_it_be(:namespace) { create(:namespace) }

    subject { described_class.find_or_initialize_by_namespace(namespace) }

    context 'no existing setting' do
      it 'initializes a setting' do
        expect(subject).to be_a(MergeRequestApprovalSetting).and be_a_new_record
      end
    end

    context 'existing setting' do
      let_it_be(:setting) { create(:merge_request_approval_setting, namespace: namespace) }

      it { is_expected.to eq(setting) }
    end
  end
end
