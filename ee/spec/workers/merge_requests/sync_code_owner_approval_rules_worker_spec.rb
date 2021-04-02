# frozen_string_literal: true

require "spec_helper"

RSpec.describe MergeRequests::SyncCodeOwnerApprovalRulesWorker do
  subject { described_class.new }

  describe "#perform" do
    context "when merge request is not found" do
      it "returns without attempting to sync code owner rules" do
        expect(MergeRequests::SyncCodeOwnerApprovalRules).not_to receive(:new)

        subject.perform(1234)
      end
    end

    context "when merge request is found" do
      let_it_be(:merge_request) { create(:merge_request) }

      it "returns without attempting to sync code owner rules" do
        expect_next_instance_of(::MergeRequests::SyncCodeOwnerApprovalRules) do |instance|
          expect(instance).to receive(:execute)
        end

        subject.perform(merge_request.id)
      end
    end
  end
end
