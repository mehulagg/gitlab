# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Timelog do
  subject { build(:timelog) }

  let(:issue) { create(:issue) }
  let(:merge_request) { create(:merge_request) }

  it { is_expected.to belong_to(:issue).touch(true) }
  it { is_expected.to belong_to(:merge_request).touch(true) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:time_spent) }
  it { is_expected.to validate_presence_of(:user) }

  describe 'Issuable validation' do
    it 'is invalid if issue_id and merge_request_id are missing' do
      subject.attributes = { issue: nil, merge_request: nil }

      expect(subject).to be_invalid
    end

    it 'is invalid if issue_id and merge_request_id are set' do
      subject.attributes = { issue: issue, merge_request: merge_request }

      expect(subject).to be_invalid
    end

    it 'is valid if only issue_id is set' do
      subject.attributes = { issue: issue, merge_request: nil }

      expect(subject).to be_valid
    end

    it 'is valid if only merge_request_id is set' do
      subject.attributes = { merge_request: merge_request, issue: nil }

      expect(subject).to be_valid
    end

    describe 'when importing' do
      it 'is valid if issue_id and merge_request_id are missing' do
        subject.attributes = { issue: nil, merge_request: nil, importing: true }

        expect(subject).to be_valid
      end
    end
  end

  describe 'scopes' do
    let(:group) { create(:group) }
    let(:group_issue) { create(:issue, project: create(:project, group: group)) }
    let(:group_merge_request) { create(:merge_request, source_project: create(:project, group: group)) }
    let(:subgroup) { create(:group, parent: group) }
    let(:subgroup_issue) { create(:issue, project: create(:project, group: subgroup)) }
    let(:subgroup_merge_request) { create(:merge_request, source_project: create(:project, group: subgroup)) }

    let(:timelog) { create(:issue_timelog, spent_at: 65.days.ago) }
    let(:timelog1) { create(:issue_timelog, spent_at: 15.days.ago, issue: group_issue) }
    let(:timelog2) { create(:issue_timelog, spent_at: 5.days.ago, issue: subgroup_issue) }
    let(:timelog3) { create(:merge_request_timelog, spent_at: 65.days.ago) }
    let(:timelog4) { create(:merge_request_timelog, spent_at: 15.days.ago, merge_request: group_merge_request) }
    let(:timelog5) { create(:merge_request_timelog, spent_at: 5.days.ago, merge_request: subgroup_merge_request) }

    describe 'in_group' do
      it 'return timelogs created for group issues and merge requests' do
        expect(described_class.in_group(group)).to contain_exactly(timelog1, timelog2, timelog4, timelog5)
      end
    end

    describe 'for_issues_in_group' do
      it 'return timelogs created for group issues' do
        expect(described_class.for_issues_in_group(group)).to contain_exactly(timelog1, timelog2)
      end
    end

    describe 'for_merge_requests_in_group' do
      it 'return timelogs created for group merge_requests' do
        expect(described_class.for_merge_requests_in_group(group)).to contain_exactly(timelog4, timelog5)
      end
    end

    describe 'between_times' do
      it 'returns collection of timelogs within given times' do
        timelogs = described_class.between_times(20.days.ago, 10.days.ago)

        expect(timelogs).to contain_exactly(timelog1, timelog4)
      end
    end
  end
end
