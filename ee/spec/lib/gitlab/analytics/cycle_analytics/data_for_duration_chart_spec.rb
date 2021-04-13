# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::CycleAnalytics::DataForDurationChart do
  describe '#average_by_day' do
    let_it_be(:project) { create(:project, :repository) }

    let(:query) { MergeRequest.joins(:metrics) }

    let(:stage) do
      build(
        :cycle_analytics_project_stage,
        start_event_identifier: Gitlab::Analytics::CycleAnalytics::StageEvents::MergeRequestCreated.identifier,
        end_event_identifier: Gitlab::Analytics::CycleAnalytics::StageEvents::MergeRequestMerged.identifier,
        project: project
      )
    end

    subject(:averages) { described_class.new(stage: stage, params: {}, query: query).average_by_day }

    it 'returns average duration by day' do
      time = Time.current
      merge_request1 = travel_to(time + 10.minutes) do
        create(:merge_request, source_branch: '1', target_project: project, source_project: project)
      end

      merge_request2 = travel_to(time + 15.minutes) do
        create(:merge_request, source_branch: '2', target_project: project, source_project: project)
      end

      travel_to(time + 20.minutes) do
        merge_request1.metrics.update!(merged_at: Time.zone.now) # 10 minutes
        merge_request2.metrics.update!(merged_at: Time.zone.now) # 5 minutes

        average = averages.first
        expect(average.date).to eq(Time.now.utc.to_date)
        expect(average.average_duration_in_seconds.to_i).to eq(7.5.minutes)
      end
    end
  end
end
