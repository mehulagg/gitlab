# frozen_string_literal: true

require 'spec_helper'

describe MergeRequests::SyncCodeOwnerApprovalRules do
  let(:merge_request) { create(:merge_request) }
  let(:rb_owners) { create_list(:user, 2) }
  let(:doc_owners) { create_list(:user, 2) }
  let(:rb_entry) { build_entry('*.rb', rb_owners) }
  let(:doc_entry) { build_entry('doc/*', doc_owners) }
  let(:entries) { [rb_entry, doc_entry] }

  def build_entry(pattern, users)
    entry = Gitlab::CodeOwners::Entry.new(pattern, users.map(&:to_reference).join(' '))
    entry.add_matching_users_from(users)

    entry
  end

  subject(:service) { described_class.new(merge_request) }

  describe '#execute' do
    before do
      allow(Gitlab::CodeOwners)
        .to receive(:entries_for_merge_request).with(merge_request, merge_request_diff: nil)
              .and_return(entries)
    end

    it "creates rules for code owner entries that don't have a rule" do
      expect { service.execute }.to change { merge_request.approval_rules.count }.by(2)

      rb_rule = merge_request.approval_rules.code_owner.find_by(name: rb_entry.pattern)
      doc_rule = merge_request.approval_rules.code_owner.find_by(name: doc_entry.pattern)

      expect(rb_rule.users).to eq(rb_owners)
      expect(doc_rule.users).to eq(doc_owners)
    end

    it 'deletes rules that are not relevant anymore' do
      other_rule = create(:code_owner_rule, merge_request: merge_request)

      service.execute

      expect(merge_request.approval_rules).not_to include(other_rule)
      expect { other_rule.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'updates rules for which the users changed' do
      other_rule = create(:code_owner_rule, merge_request: merge_request, name: '*.rb')
      other_rule.users += doc_owners
      other_rule.save!

      service.execute

      expect(other_rule.reload.users).to eq(rb_owners)
    end

    context 'when multiple code owner rules are disabled' do
      before do
        stub_feature_flags(multiple_code_owner_rules: false)
      end

      it 'calls the old sync method' do
        expect(merge_request).to receive(:sync_code_owners_with_approvers)

        service.execute
      end
    end
  end
end
