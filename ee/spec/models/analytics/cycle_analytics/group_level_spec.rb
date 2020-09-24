# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CycleAnalytics::GroupLevel do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:from_date) { 10.days.ago }
  let_it_be(:user) { create(:user) }
  let(:issue) { create(:issue, project: project, created_at: 2.days.ago) }
  let_it_be(:milestone) { create(:milestone, project: project) }
  let(:mr) { create_merge_request_closing_issue(user, project, issue, commit_message: "References #{issue.to_reference}") }
  let(:pipeline) { create(:ci_empty_pipeline, status: 'created', project: project, ref: mr.source_branch, sha: mr.source_branch_sha, head_pipeline_of: mr) }

  around do |example|
    Timecop.freeze { example.run }
  end

  subject { described_class.new(group: group, options: { from: from_date, current_user: user }) }

  before do
    # Cannot set the owner directly when calling `create(:group)`
    # See spec/factories/groups.rb#after(:create)
    group.add_owner(user)
  end

  describe '#permissions' do
    it 'returns true for all stages' do
      expect(subject.permissions.values.uniq).to eq([true])
    end
  end

  describe '#stats' do
    before do
      create_cycle(user, project, issue, mr, milestone, pipeline)
      deploy_master(user, project)
    end

    it 'returns medians for each stage for a specific group' do
      expect(subject.no_stats?).to eq(false)
    end
  end

  describe '#summary' do
    before do
      create_cycle(user, project, issue, mr, milestone, pipeline)
      deploy_master(user, project)
    end

    it 'returns medians for each stage for a specific group' do
      expect(subject.summary.map { |summary| summary[:value] }).to contain_exactly('0.1', '1', '1')
    end
  end

  describe '#time_summary' do
    let(:issue) { create(:issue, project: project) }

    before do
      # lead_time: 1 day, cycle_time: 2 days

      issue.update!(created_at: 5.days.ago)

      issue.metrics.update!(first_mentioned_in_commit_at: 4.days.ago)

      issue.update!(closed_at: 3.days.ago)
    end

    it 'returns medians for lead time and cycle type' do
      expect(subject.time_summary.map { |summary| summary[:value] }).to contain_exactly('1.0', '2.0')
    end
  end
end
