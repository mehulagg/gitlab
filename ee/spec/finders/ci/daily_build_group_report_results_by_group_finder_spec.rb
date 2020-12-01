# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DailyBuildGroupReportResultsByGroupFinder do
  describe '#execute' do
    let_it_be(:user) { create(:user) }

    let_it_be(:project) { create(:project, :private) }
    let_it_be(:project_coverage) { create_daily_coverage('rspec', 95.0, '2020-03-10', project) }

    let_it_be(:group) { create(:group, :private) }
    let_it_be(:rspec_project) { create(:project, namespace: group) }
    let_it_be(:rspec_project_coverage) { create_daily_coverage('rspec', 79.0, '2020-03-09', rspec_project) }

    let_it_be(:karma_project) { create(:project, namespace: group) }
    let_it_be(:karma_project_coverage) { create_daily_coverage('karma', 89.0, '2020-03-09', karma_project) }

    let_it_be(:generic_project) { create(:project, namespace: group) }
    let_it_be(:generic_coverage) { create_daily_coverage('unreported', 95.0, '2020-03-10', generic_project) }

    let_it_be(:subgroup) { create(:group, :private, parent: group) }
    let_it_be(:subgroup_project) { create(:project, namespace: subgroup) }
    let_it_be(:subgroup_project_coverage) { create_daily_coverage('rspec', 89.0, '2020-03-09', subgroup_project) }

    let(:limit) { nil }
    let(:project_ids) { nil }

    let(:attributes) do
      {
        current_user: user,
        group: group,
        project_ids: project_ids,
        ref_path: 'refs/heads/master',
        start_date: '2020-03-09',
        end_date: '2020-03-10',
        limit: limit
      }
    end

    subject do
      described_class.new(**attributes).execute
    end

    context 'when current user is allowed to :read_group_build_report_results' do
      before do
        group.add_reporter(user)
      end

      it 'returns only coverages belonging to the passed group' do
        expect(subject).to include(rspec_project_coverage, karma_project_coverage)
        expect(subject).not_to include(project_coverage)
        expect(subject).not_to include(subgroup_project_coverage)
      end

      context 'with a limit below 1000' do
        let(:limit) { 5 }

        it 'uses the provided limit' do
          expect(subject.limit_value).to eq(5)
        end
      end

      context 'with a limit above 1000' do
        let(:limit) { 1001 }

        it 'uses the max constant' do
          expect(subject.limit_value).to eq(Ci::DailyBuildGroupReportResultsByGroupFinder::GROUP_QUERY_RESULT_LIMIT)
        end
      end

      context 'without a limit' do
        it 'uses the max constant' do
          expect(subject.limit_value).to eq(Ci::DailyBuildGroupReportResultsByGroupFinder::GROUP_QUERY_RESULT_LIMIT)
        end
      end

      context 'with nil project_ids' do
        it 'returns only coverages belonging to the passed group' do
          expect(subject).to match_array([rspec_project_coverage, karma_project_coverage, generic_coverage])
          expect(subject).not_to include(project_coverage)
          expect(subject).not_to include(subgroup_project_coverage)
        end
      end

      context 'with passed project_ids' do
        let(:project_ids) { [rspec_project.id] }

        it 'filters out non-specified projects' do
          expect(subject).to match_array([rspec_project_coverage])
          expect(subject).not_to include(karma_project_coverage, generic_coverage)
        end
      end

      context 'with empty project_ids' do
        let(:project_ids) { [] }

        it 'returns all projects' do
          expect(subject).to match_array([rspec_project_coverage, karma_project_coverage, generic_coverage])
        end
      end
    end

    context 'without permmissions' do
      it 'returns an empty result' do
        expect(subject).to be_empty
      end
    end
  end

  private

  def create_daily_coverage(group_name, coverage, date, project)
    create(
      :ci_daily_build_group_report_result,
      project: project,
      ref_path: 'refs/heads/master',
      group_name: group_name,
      data: { 'coverage' => coverage },
      date: date
    )
  end
end
