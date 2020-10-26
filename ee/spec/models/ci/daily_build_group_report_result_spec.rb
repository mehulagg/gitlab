# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DailyBuildGroupReportResult do
  let_it_be(:project) { create(:project) }
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
  end
end
