# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::SnapshotCalculator do
  let_it_be(:group1) { create(:group) }
  let_it_be(:segment) { create(:devops_adoption_segment, namespace: group1) }
  let_it_be(:subgroup) { create(:group, parent: group1) }
  let_it_be(:project) { create(:project, group: group1) }
  let_it_be(:subproject) { create(:project, group: subgroup) }
  let_it_be(:range_end) { Time.zone.parse('2020-12-01').end_of_month }

  subject(:data) { described_class.new(segment: segment, range_end: range_end).calculate }

  describe 'end_time' do
    it 'equals to range_end' do
      expect(data[:end_time]).to be_like_time range_end
    end
  end

  describe 'issue_opened' do
    subject { data[:issue_opened] }

    let_it_be(:old_issue) { create(:issue, project: subproject, created_at: 1.year.ago(range_end)) }

    context 'with an issue opened within month' do
      let_it_be(:fresh_issue) { create(:issue, project: project, created_at: 3.weeks.ago(range_end)) }

      it { is_expected.to eq true }
    end

    it { is_expected.to eq false }
  end

  describe 'merge_request_opened' do
    subject { data[:merge_request_opened] }

    let!(:old_merge_request) { create(:merge_request, source_project: subproject, created_at: 1.year.ago(range_end)) }

    context 'with a merge request opened within month' do
      let!(:fresh_merge_request) { create(:merge_request, source_project: project, created_at: 3.weeks.ago(range_end)) }

      it { is_expected.to eq true }
    end

    it { is_expected.to eq false }
  end

  describe 'merge_request_approved' do
    subject { data[:merge_request_approved] }

    let!(:old_merge_request) { create(:merge_request, source_project: subproject, created_at: 1.year.ago(range_end)) }
    let!(:old_approval) { create(:approval, merge_request: old_merge_request, created_at: 6.months.ago(range_end)) }

    context 'with a merge request approved within month' do
      let!(:fresh_approval) { create(:approval, merge_request: old_merge_request, created_at: 3.weeks.ago(range_end)) }

      it { is_expected.to eq true }
    end

    it { is_expected.to eq false }
  end

  describe 'runner_configured' do
    subject { data[:runner_configured] }

    let!(:inactive_runner) { create(:ci_runner, :project, active: false) }
    let!(:ci_runner_project) { create(:ci_runner_project, project: project, runner: inactive_runner) }

    context 'with active runner present' do
      let!(:active_runner) { create(:ci_runner, :project, active: true) }
      let!(:ci_runner_project) { create(:ci_runner_project, project: subproject, runner: active_runner) }

      it { is_expected.to eq true }
    end

    it { is_expected.to eq false }
  end

  describe 'pipeline_succeeded' do
    subject { data[:pipeline_succeeded] }

    let!(:failed_pipeline) { create(:ci_pipeline, :failed, project: project, updated_at: 1.day.ago(range_end)) }
    let!(:old_pipeline) { create(:ci_pipeline, :success, project: project, updated_at: 100.days.ago(range_end)) }

    context 'with successful pipeline within month' do
      let!(:fresh_pipeline) { create(:ci_pipeline, :success, project: project, updated_at: 1.week.ago(range_end)) }

      it { is_expected.to eq true }
    end

    it { is_expected.to eq false }
  end

  describe 'deploy_succeeded' do
    subject { data[:deploy_succeeded] }

    let!(:deployment) { create(:deployment, :success, updated_at: deployed_at) }
    let(:deployed_at) { 100.days.ago(range_end) }

    let(:segment) { create(:devops_adoption_segment, namespace: group) }
    let!(:group) do
      create(:group).tap do |g|
        g.projects << deployment.project
      end
    end

    it { is_expected.to eq false }

    context 'with successful deployment within month' do
      let(:deployed_at) { 1.day.ago(range_end) }

      it { is_expected.to eq true }
    end
  end

  describe 'security_scan_succeeded' do
    subject { data[:security_scan_succeeded] }

    let!(:old_security_scan) { create :security_scan, build: create(:ci_build, project: project), created_at: 100.days.ago(range_end) }

    context 'with successful security scan within month' do
      let!(:fresh_security_scan) { create :security_scan, build: create(:ci_build, project: project), created_at: 10.days.ago(range_end) }

      it { is_expected.to eq true }
    end

    it { is_expected.to eq false }
  end

  context 'when snapshot already exists' do
    let_it_be(:snapshot) { create :devops_adoption_snapshot, segment: segment, issue_opened: true, merge_request_opened: false }

    subject(:data) { described_class.new(segment: segment, range_end: range_end, snapshot: snapshot).calculate }

    let!(:fresh_merge_request) { create(:merge_request, source_project: project, created_at: 3.weeks.ago(range_end)) }

    it 'calculates metrics which are not true yet' do
      expect(data[:merge_request_opened]).to eq true
    end

    it "doesn't change metrics which are true already" do
      expect(data[:issue_opened]).to eq true
    end
  end
end
