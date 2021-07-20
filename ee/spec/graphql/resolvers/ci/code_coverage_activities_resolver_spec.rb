# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ci::CodeCoverageActivitiesResolver do
  include GraphqlHelpers

  it { expect(described_class.type).to eq(Types::Ci::CodeCoverageActivityType) }
  it { expect(described_class.null).to be_truthy }

  describe '#resolve' do
    let_it_be(:current_user) { create(:user) }
    let_it_be(:project_1) { create(:project) }
    let_it_be(:project_2) { create(:project) }
    let_it_be(:group) { create(:group, projects: [project_1, project_2]) }

    let(:start_date) { 1.day.ago.to_date.to_s }

    context 'when group has projects with coverage' do
      let!(:coverage_1) { create(:ci_daily_build_group_report_result, project: project_1, group: group) }
      let!(:coverage_2) { create(:ci_daily_build_group_report_result, project: project_2, group: group) }

      it 'returns coverage activity for the group' do
        expected_results = expected_activities(
          average_coverage: 77.0,
          coverage_count: 2,
          date: Date.current,
          project_count: 2
        )

        results = resolve_coverages(start_date: start_date)

        expect(results).to contain_exactly(expected_results)
      end
    end

    context 'when group has projects without coverage' do
      it 'returns an empty collection' do
        results = resolve_coverages(start_date: start_date)

        expect(results).to be_empty
      end
    end

    context 'when coverage is included within start date' do
      let!(:coverage_1) { create(:ci_daily_build_group_report_result, project: project_1, date: 1.week.ago, group: group) }
      let!(:coverage_2) { create(:ci_daily_build_group_report_result, project: project_1, date: 1.week.ago, group_name: 'karma', group: group) }
      let(:start_date) { 1.week.ago.to_date.to_s }

      it 'returns coverage from the start_date' do
        expected_results = expected_activities(
          average_coverage: 77.0,
          coverage_count: 2,
          date: 1.week.ago,
          project_count: 1
        )

        results = resolve_coverages(start_date: start_date)

        expect(results).to contain_exactly(expected_results)
      end
    end

    context 'when coverage is not included within start date' do
      let!(:coverage_1) { create(:ci_daily_build_group_report_result, project: project_1, date: 1.week.ago) }
      let!(:coverage_2) { create(:ci_daily_build_group_report_result, project: project_1, date: 2.weeks.ago) }

      it 'returns an empty collection' do
        results = resolve_coverages(start_date: start_date)

        expect(results).to be_empty
      end
    end
  end

  def resolve_coverages(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: group, args: args, ctx: context)
  end

  def expected_activities(args = {})
    {
      average_coverage: args[:average_coverage],
      coverage_count: args[:coverage_count],
      date: args[:date].to_date,
      project_count: args[:project_count]
    }
  end
end
