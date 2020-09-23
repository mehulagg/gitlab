# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApprovalRules::ProjectRuleDestroyService do
  let(:project) { create(:project, :repository) }
  let(:merge_request) { create(:merge_request, source_project: project, target_project: project) }

  describe '#execute' do
    let!(:project_rule) { create(:approval_project_rule, project: project) }

    subject { described_class.new(project_rule) }

    context 'when there is no merge request rules' do
      it 'destroys project rule' do
        expect { subject.execute }.to change { ApprovalProjectRule.count }.by(-1)
      end
    end

    context 'when there is a merge request rule' do
      let!(:merge_request_rule) do
        create(:approval_merge_request_rule, merge_request: merge_request).tap do |rule|
          rule.approval_project_rule = project_rule
        end
      end

      context 'when open' do
        it 'destroys merge request rules' do
          expect { subject.execute }.to change { ApprovalMergeRequestRule.count }.by(-1)
        end
      end

      context 'when merged' do
        before do
          merge_request.mark_as_merged!
        end

        it 'does nothing' do
          expect { subject.execute }.not_to change { ApprovalMergeRequestRule.count }
        end
      end
    end
  end
end
