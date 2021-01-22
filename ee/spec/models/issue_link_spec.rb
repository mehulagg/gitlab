# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssueLink do
  context 'callbacks' do
    let_it_be(:target) { create(:issue) }
    let_it_be(:source) { create(:issue) }

    describe '.after_create_commit' do
      context 'with TYPE_BLOCKS relation' do
        it 'updates blocking issues count' do
          expect(source).to receive(:update_blocking_issues_count!)
          expect(target).not_to receive(:update_blocking_issues_count!)

          create(:issue_link, target: target, source: source, link_type: ::IssueLink::TYPE_BLOCKS)
        end
      end

      context 'with TYPE_RELATES_TO' do
        it 'does not update blocking_issues_count' do
          expect(source).not_to receive(:update_blocking_issues_count!)
          expect(target).not_to receive(:update_blocking_issues_count!)

          create(:issue_link, target: target, source: source, link_type: ::IssueLink::TYPE_RELATES_TO)
        end
      end
    end

    describe '.after_destroy_commit' do
      context 'with TYPE_BLOCKS relation' do
        it 'updates blocking issues count' do
          link = create(:issue_link, target: target, source: source, link_type: ::IssueLink::TYPE_BLOCKS)

          expect(source).to receive(:update_blocking_issues_count!)
          expect(target).not_to receive(:update_blocking_issues_count!)

          link.destroy!
        end
      end

      context 'with TYPE_RELATES_TO' do
        it 'does not update blocking_issues_count' do
          link = create(:issue_link, target: target, source: source, link_type: ::IssueLink::TYPE_RELATES_TO)

          expect(source).not_to receive(:update_blocking_issues_count!)
          expect(target).not_to receive(:update_blocking_issues_count!)

          link.destroy!
        end
      end
    end
  end

  describe '.blocked_issue_ids' do
    it 'returns only ids of issues which are blocked' do
      link1 = create(:issue_link, link_type: ::IssueLink::TYPE_BLOCKS)
      link2 = create(:issue_link, link_type: ::IssueLink::TYPE_RELATES_TO)
      link3 = create(:issue_link, source: create(:issue, :closed), link_type: ::IssueLink::TYPE_BLOCKS)

      expect(described_class.blocked_issue_ids([link1.target_id, link2.source_id, link3.target_id]))
        .to match_array([link1.target_id])
    end
  end

  describe '.blocking_issue_ids_for' do
    it 'returns blocking issue ids' do
      issue = create(:issue)
      blocking_issue = create(:issue, project: issue.project)
      blocked_by_issue = create(:issue, project: issue.project)
      create(:issue_link, source: blocking_issue, target: issue, link_type: ::IssueLink::TYPE_BLOCKS)
      create(:issue_link, source: blocked_by_issue, target: issue, link_type: ::IssueLink::TYPE_BLOCKS)

      blocking_ids = described_class.blocking_issue_ids_for(issue)

      expect(blocking_ids).to match_array([blocking_issue.id, blocked_by_issue.id])
    end
  end

  describe '.inverse_link_type' do
    it 'returns reverse type of link' do
      expect(described_class.inverse_link_type('relates_to')).to eq 'relates_to'
      expect(described_class.inverse_link_type('blocks')).to eq 'is_blocked_by'
      expect(described_class.inverse_link_type('is_blocked_by')).to eq 'blocks'
    end
  end

  context 'blocking issues count' do
    let_it_be(:blocked_issue_1) { create(:issue) }
    let_it_be(:project) { blocked_issue_1.project }
    let_it_be(:blocked_issue_2) { create(:issue, project: project) }
    let_it_be(:blocked_issue_3) { create(:issue, project: project) }
    let_it_be(:blocking_issue_1) { create(:issue, project: project) }
    let_it_be(:blocking_issue_2) { create(:issue, project: project) }

    before :all do
      create(:issue_link, source: blocking_issue_1, target: blocked_issue_1, link_type: ::IssueLink::TYPE_BLOCKS)
      create(:issue_link, source: blocking_issue_1, target: blocked_issue_2, link_type: ::IssueLink::TYPE_BLOCKS)
      create(:issue_link, source: blocking_issue_2, target: blocked_issue_3, link_type: ::IssueLink::TYPE_BLOCKS)
    end

    describe '.blocking_issues_for_collection' do
      it 'returns blocking issues count grouped by issue id' do
        results = described_class.blocking_issues_for_collection([blocking_issue_1, blocking_issue_2])

        expect(results.find { |link| link.blocking_issue_id == blocking_issue_1.id }.count).to eq(2)
        expect(results.find { |link| link.blocking_issue_id == blocking_issue_2.id }.count).to eq(1)
      end
    end

    describe '.blocked_issues_for_collection' do
      it 'returns blocked issues count grouped by issue id' do
        results = described_class.blocked_issues_for_collection([blocked_issue_1, blocked_issue_2, blocked_issue_3])

        expect(result_by(results, blocked_issue_1.id).count).to eq(1)
        expect(result_by(results, blocked_issue_2.id).count).to eq(1)
        expect(result_by(results, blocked_issue_3.id).count).to eq(1)
      end
    end

    describe '.blocking_issues_count_for' do
      it 'returns blocked issues count for single issue' do
        blocking_count = described_class.blocking_issues_count_for(blocking_issue_1)

        expect(blocking_count).to eq(2)
      end
    end
  end

  def result_by(results, id)
    results.find { |link| link.blocked_issue_id == id }
  end
end
