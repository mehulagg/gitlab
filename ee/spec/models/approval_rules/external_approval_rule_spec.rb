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

  describe 'to_h' do
    it 'returns the correct information' do
      expect(subject.to_h).to eq({ id: subject.id, name: subject.name, external_url: subject.external_url })
    end
  end

  describe 'approved?' do
    let_it_be(:rule) { create(:external_approval_rule) }
    let_it_be(:merge_request) { create(:merge_request) }

    let(:project) { merge_request.source_project }

    subject { rule.approved?(merge_request, merge_request.source_branch_sha) }

    context 'when a rule has a positive status check response' do
      let_it_be(:status_check_response) { create(:status_check_response, merge_request: merge_request, external_approval_rule: rule, sha: merge_request.source_branch_sha) }

      it { is_expected.to be true }

      context 'when a rule also has a positive check response from an old sha' do
        before do
          create(:status_check_response, merge_request: merge_request, external_approval_rule: rule, sha: 'abc1234')
        end

        it { is_expected.to be true }
      end
    end

    context 'when a rule has no positive status check response' do
      it { is_expected.to be false }
    end

    context 'when a rule has a positive status check response from an old sha' do
      before do
        create(:status_check_response, merge_request: merge_request, external_approval_rule: rule, sha: 'abc123')
      end

      it { is_expected.to be false }
    end
  end
end
