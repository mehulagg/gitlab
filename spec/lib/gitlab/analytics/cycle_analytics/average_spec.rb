# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::CycleAnalytics::Average do
  let_it_be(:project) { create(:project) }
  let_it_be(:issue_1) { create(:issue, project: project, created_at: 20.days.ago, closed_at: 10.days.ago) } # 10 days
  let_it_be(:issue_2) { create(:issue, project: project, created_at: 15.days.ago, closed_at: 10.days.ago) } # 5 days

  let(:stage) do
    build(
      :cycle_analytics_project_stage,
      start_event_identifier: Gitlab::Analytics::CycleAnalytics::StageEvents::IssueCreated.identifier,
      end_event_identifier: Gitlab::Analytics::CycleAnalytics::StageEvents::IssueClosed.identifier,
      project: project
    )
  end

  let(:query) { Issue.in_projects(project.id) }

  around do |example|
    freeze_time { example.run }
  end

  describe '#seconds' do
    subject(:average_duration_in_seconds) { described_class.new(stage: stage, query: query).seconds }

    context 'when no results' do
      let(:query) { Issue.none }

      it { is_expected.to eq(nil) }
    end

    context 'returns the average duration in seconds' do
      it { is_expected.to be_within(0.5).of(7.5.days.to_f) }
    end
  end

  describe '#days' do
    subject(:average_duration_in_seconds) { described_class.new(stage: stage, query: query).days }

    context 'when no results' do
      let(:query) { Issue.none }

      it { is_expected.to eq(nil) }
    end

    context 'returns the average duration in seconds' do
      it { is_expected.to be_within(0.5).of(7.5) }
    end
  end
end
