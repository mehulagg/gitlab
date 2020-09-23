# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApprovalRules::MergeRequestRuleDestroyService do
  let(:rule) { create(:approval_merge_request_rule) }
  let(:user) { create(:user) }

  subject(:result) { described_class.new(rule, user).execute }

  before do
    allow(Ability).to receive(:allowed?).and_call_original
    allow(Ability)
      .to receive(:allowed?)
      .with(user, :edit_approval_rule, rule)
      .at_least(:once)
      .and_return(can_edit?)
  end

  context 'user cannot edit approval rule' do
    let(:can_edit?) { false }

    it 'returns error status' do
      expect(result[:status]).to eq(:error)
    end
  end

  context 'user can edit approval rule' do
    let(:can_edit?) { true }

    context 'when rule successfully deleted' do
      it 'returns successful status' do
        expect(result[:status]).to eq(:success)
      end
    end

    context 'when rule not successfully deleted' do
      before do
        allow(rule).to receive(:destroyed?).and_return(false)
      end

      it 'returns error status' do
        expect(result[:status]).to eq(:error)
      end
    end
  end
end
