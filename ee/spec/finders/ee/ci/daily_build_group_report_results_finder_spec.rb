# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DailyBuildGroupReportResultsFinder do
  describe '#execute' do
    let_it_be(:current_user) { create(:user) }
    let_it_be(:group) { create(:group, :private) }
    let_it_be(:rspec_project) { create(:project, namespace: group) }
    let_it_be(:rspec_coverage) { create_daily_coverage('rspec', 95.0, '2020-03-10', rspec_project, group) }
    let_it_be(:karma_project) { create(:project, namespace: group) }
    let_it_be(:karma_coverage) { create_daily_coverage('karma', 89.0, '2020-03-09', karma_project, group) }
    let_it_be(:generic_project) { create(:project) }
    let_it_be(:generic_coverage) { create_daily_coverage('unreported', 95.0, '2020-03-10', generic_project) }

    let(:ref_path) { 'refs/heads/master' }
    let(:start_date) { '2020-03-09' }
    let(:end_date) { '2020-03-10' }
    let(:limit) { nil }
    let(:sort) { true }

    let(:params) do
      {
        group: group,
        coverage: true,
        ref_path: ref_path,
        start_date: start_date,
        end_date: end_date,
        sort: sort,
        limit: limit
      }
    end

    let(:finder) { described_class.new(params: params, current_user: current_user) }

    subject(:coverages) { finder.execute }

    context 'with permissions' do
      before do
        group.add_reporter(current_user)
      end

      it 'returns coverages belonging to the group' do
        expect(coverages).to contain_exactly(rspec_coverage, karma_coverage)
      end

      context 'with a limit below 1000' do
        let(:limit) { 5 }

        it 'uses the provided limit' do
          expect(coverages.limit_value).to eq(5)
        end
      end

      context 'with a limit above 1000' do
        let(:limit) { 1001 }

        it 'returns MAX_ITEMS as a limit' do
          expect(coverages.limit_value).to eq(Ci::DailyBuildGroupReportResultsFinder::MAX_ITEMS)
        end
      end

      context 'without a limit' do
        it 'returns MAX_ITEMS as a limit' do
          expect(coverages.limit_value).to eq(Ci::DailyBuildGroupReportResultsFinder::MAX_ITEMS)
        end
      end
    end

    context 'without permmissions' do
      it 'returns an empty result' do
        expect(coverages).to be_empty
      end
    end
  end

  private

  def create_daily_coverage(group_name, coverage, date, project, group = nil)
    create(
      :ci_daily_build_group_report_result,
      project: project,
      ref_path: 'refs/heads/master',
      group_name: group_name,
      data: { 'coverage' => coverage },
      date: date,
      group: group
    )
  end
end
