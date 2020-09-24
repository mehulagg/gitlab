# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::IssuableMetadata do
  let_it_be(:user) { create(:user) }
  let_it_be(:project1) { create(:project, :public, :repository, creator: user, namespace: user.namespace) }
  let_it_be(:project2) { create(:project, :public, :repository, creator: user, namespace: user.namespace) }

  context 'issues' do
    # blocked issues
    let_it_be(:blocked_issue_1) { create(:issue, author: user, project: project1) }
    let_it_be(:blocked_issue_2) { create(:issue, author: user, project: project2) }
    let_it_be(:blocked_issue_3) { create(:issue, author: user, project: project1) }
    let_it_be(:closed_blocked_issue) { create(:issue, author: user, project: project2, state: :closed) }
    # blocking issues (as target or source)
    let_it_be(:blocking_issue_1) { create(:issue, project: project1) }
    let_it_be(:blocking_issue_2) { create(:issue, project: project2) }

    before_all do
      create(:issue_link, source: blocking_issue_1, target: blocked_issue_1, link_type: IssueLink::TYPE_BLOCKS)
      create(:issue_link, source: blocking_issue_2, target: blocked_issue_2, link_type: IssueLink::TYPE_BLOCKS)
      create(:issue_link, source: blocking_issue_1, target: closed_blocked_issue, link_type: IssueLink::TYPE_BLOCKS)
      create(:issue_link, source: blocked_issue_3, target: blocking_issue_1, link_type: IssueLink::TYPE_IS_BLOCKED_BY)
    end

    it 'aggregates stats on issues' do
      data = described_class.new(user, Issue.all.limit(6)).data # rubocop: disable CodeReuse/ActiveRecord

      expect(data.count).to eq(6)
      expect(data[blocking_issue_1.id].blocking_issues_count).to eq(2)
      expect(data[blocking_issue_2.id].blocking_issues_count).to eq(1)
      expect(data[blocked_issue_1.id].blocking_issues_count).to eq(0)
    end

    context 'when blocking_issues_counts feature flag is disabled' do
      before do
        stub_feature_flags(blocking_issues_counts: false)
      end

      it 'does not return blocking_issues_counts' do
        create(:award_emoji, :upvote, awardable: blocking_issue_1)

        meta_data = described_class.new(user, Issue.all.limit(7)).data # rubocop: disable CodeReuse/ActiveRecord

        expect(meta_data.values.map { |value| value.blocking_issues_count }.uniq).to eq([nil])
        # Make sure other properties are still being fetched
        expect(meta_data[blocking_issue_1.id].upvotes).to eq(1)
      end
    end
  end
end
