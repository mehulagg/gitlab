# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::TimeboxReportResolver do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:issues) { create_list(:issue, 2, project: project) }
  let_it_be(:start_date) { Date.today }
  let_it_be(:due_date) { start_date + 2.weeks }

  before do
    stub_licensed_features(milestone_charts: true, issue_weights: true, iterations: true)
  end

  RSpec.shared_examples 'timebox time series' do
    subject { resolve(described_class, obj: timebox) }

    context 'when the feature flag is disabled' do
      before do
        stub_feature_flags(burnup_charts: false, iteration_charts: false)
      end

      it 'returns empty data' do
        expect(subject).to be_empty
      end
    end

    context 'when the feature flag is enabled' do
      before do
        stub_feature_flags(burnup_charts: true, iteration_charts: true)
      end

      it 'returns burnup chart data' do
        expect(subject).to eq(
          stats: {
            complete: { count: 0, weight: 0 },
            incomplete: { count: 2, weight: 0 },
            total: { count: 2, weight: 0 }
          },
          burnup_time_series: [
          {
            date: start_date + 4.days,
            scope_count: 1,
            scope_weight: 0,
            completed_count: 0,
            completed_weight: 0
          },
          {
            date: start_date + 9.days,
            scope_count: 2,
            scope_weight: 0,
            completed_count: 0,
            completed_weight: 0
          }
        ])
      end

      context 'when the service returns an error' do
        before do
          stub_const('TimeboxReportService::EVENT_COUNT_LIMIT', 1)
        end

        it 'raises a GraphQL exception' do
          expect { subject }.to raise_error(GraphQL::ExecutionError, 'Burnup chart could not be generated due to too many events')
        end
      end
    end
  end

  context 'when timebox is a milestone' do
    let_it_be(:timebox) { create(:milestone, project: project, start_date: start_date, due_date: due_date) }

    before_all do
      create(:resource_milestone_event, issue: issues[0], milestone: timebox, action: :add, created_at: start_date + 4.days)
      create(:resource_milestone_event, issue: issues[1], milestone: timebox, action: :add, created_at: start_date + 9.days)
    end

    it_behaves_like 'timebox time series'
  end

  context 'when timebox is an iteration' do
    let_it_be(:timebox) { create(:iteration, group: group, start_date: start_date, due_date: due_date) }

    before_all do
      create(:resource_iteration_event, issue: issues[0], iteration: timebox, action: :add, created_at: start_date + 4.days)
      create(:resource_iteration_event, issue: issues[1], iteration: timebox, action: :add, created_at: start_date + 9.days)
    end

    it_behaves_like 'timebox time series'
  end
end
