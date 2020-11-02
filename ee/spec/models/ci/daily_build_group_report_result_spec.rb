# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DailyBuildGroupReportResult do
  let_it_be(:project) { create(:project) }
  let_it_be(:group) { create(:group, projects: [project]) }
  let(:recent_build_group_report_result) { create(:ci_daily_build_group_report_result, project: project) }
  let(:old_build_group_report_result) do
    create(:ci_daily_build_group_report_result, date: 1.week.ago, project: project)
  end

  describe 'scopes' do
    describe '.latest' do
      subject { described_class.latest }

      it 'returns the most recent records by date and projects' do
        expect(subject).to contain_exactly(recent_build_group_report_result)
      end
    end

    describe '.summaries_per_project' do
      subject(:summary) { described_class.latest.summaries_per_project }

      context 'when projects with coverages' do
        let_it_be(:project_2) { create(:project) }
        let_it_be(:new_build_group_report_result) do
          create(:ci_daily_build_group_report_result, project: project, group_name: 'cobertura', coverage: 66.0)
        end
        let_it_be(:build_group_report_result_2) do
          create(:ci_daily_build_group_report_result, project: project_2, group_name: 'rspec', coverage: 78.0)
        end

        it 'returns the code coverage summary by project' do
          expected_summary = {
            project.id => {
              average_coverage: 71.5,
              coverage_count: 2,
              last_updated_at: recent_build_group_report_result.date
            },
            project_2.id => {
              average_coverage: 78.0,
              coverage_count: 1,
              last_updated_at: build_group_report_result_2.date
            }
          }

          expect(summary).to eq(expected_summary)
        end

        it 'executes only 1 SQL query' do
          query_count = ActiveRecord::QueryRecorder.new { subject }.count

          expect(query_count).to eq(1)
        end
      end

      context 'when project does not have coverage' do
        it 'returns an empty hash' do
          expect(subject).to eq({})
        end

        it 'executes only 1 SQL query' do
          query_count = ActiveRecord::QueryRecorder.new { subject }.count

          expect(query_count).to eq(1)
        end
      end
    end

    describe '.activity_per_group' do
      subject(:activity) { described_class.activity_per_group }

      context 'when group has project with several coverage' do
        let!(:coverage_1) { create(:ci_daily_build_group_report_result, project: project) }
        let!(:coverage_2) { create(:ci_daily_build_group_report_result, project: project, group_name: 'karma', coverage: 88.8) }

        it 'returns coverage activity for the group' do
          expected_results = expected_activities(
            average_coverage: 82.9,
            coverage_count: 2,
            date: Date.current,
            project_count: 1
          )

          expect(activity).to contain_exactly(expected_results)
        end
      end

      context 'when group has projects with several coverage' do
        let!(:project_2) { create(:project) }
        let!(:group) { create(:group, projects: [project, project_2]) }
        let!(:coverage_1) { create(:ci_daily_build_group_report_result, project: project) }
        let!(:coverage_2) { create(:ci_daily_build_group_report_result, project: project_2, group_name: 'karma') }

        it 'returns coverage activity for the group' do
          expected_results = expected_activities(
            average_coverage: 77.0,
            coverage_count: 2,
            date: Date.current,
            project_count: 2
          )

          expect(subject).to contain_exactly(expected_results)
        end
      end

      context 'when group has projects without coverage' do
        it 'returns an empty collection' do
          expect(activity).to be_empty
        end
      end
    end
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
