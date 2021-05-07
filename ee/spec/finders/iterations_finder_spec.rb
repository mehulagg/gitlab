# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IterationsFinder do
  let(:now) { Time.now }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:project_1) { create(:project, namespace: group) }
  let_it_be(:project_2) { create(:project, namespace: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:iteration_cadence1) { create(:iterations_cadence, group: group, active: true, duration_in_weeks: 1, title: 'one week iterations') }
  let_it_be(:iteration_cadence2) { create(:iterations_cadence, group: group, active: true, duration_in_weeks: 2, title: 'two week iterations') }

  let!(:started_group_iteration) { create(:started_iteration, :skip_future_date_validation, iterations_cadence: iteration_cadence2, group: iteration_cadence2.group, title: 'one test', start_date: now - 1.day, due_date: now) }
  let!(:upcoming_group_iteration) { create(:iteration, iterations_cadence: iteration_cadence1, group: iteration_cadence1.group, start_date: 1.day.from_now, due_date: 2.days.from_now) }
  let!(:iteration_from_project_1) { create(:started_iteration, :skip_project_validation, project: project_1, start_date: 3.days.from_now, due_date: 4.days.from_now) }
  let!(:iteration_from_project_2) { create(:started_iteration, :skip_project_validation, project: project_2, start_date: 5.days.from_now, due_date: 6.days.from_now) }
  let(:project_ids) { [project_1.id, project_2.id] }

  subject { described_class.new(user, params).execute }

  context 'without permissions' do
    context 'groups and projects' do
      let(:params) { { project_ids: project_ids, group_ids: group.id } }

      it 'returns iterations for groups and projects' do
        expect(subject).to be_empty
      end
    end
  end

  context 'with permissions' do
    before do
      group.add_reporter(user)
      project_1.add_reporter(user)
      project_2.add_reporter(user)
    end

    context 'iterations for projects' do
      let(:params) { { project_ids: project_ids } }

      it 'returns iterations for projects' do
        expect(subject).to contain_exactly(iteration_from_project_1, iteration_from_project_2)
      end
    end

    context 'iterations for groups' do
      let(:params) { { group_ids: group.id } }

      it 'returns iterations for groups' do
        expect(subject).to contain_exactly(started_group_iteration, upcoming_group_iteration)
      end
    end

    context 'iterations for groups and project' do
      let(:params) { { project_ids: project_ids, group_ids: group.id } }

      it 'returns iterations for groups and projects' do
        expect(subject).to contain_exactly(started_group_iteration, upcoming_group_iteration, iteration_from_project_1, iteration_from_project_2)
      end

      it 'orders iterations by due date' do
        iteration = create(:iteration, :skip_future_date_validation, group: group, start_date: now - 3.days, due_date: now - 2.days)

        expect(subject.first).to eq(iteration)
        expect(subject.second).to eq(started_group_iteration)
        expect(subject.third).to eq(upcoming_group_iteration)
      end
    end

    context 'with filters' do
      let(:params) do
        {
          project_ids: project_ids,
          group_ids: group.id
        }
      end

      before do
        started_group_iteration.close
        iteration_from_project_1.close
      end

      it 'filters by all states' do
        params[:state] = 'all'

        expect(subject).to contain_exactly(started_group_iteration, upcoming_group_iteration, iteration_from_project_1, iteration_from_project_2)
      end

      it 'filters by started state' do
        params[:state] = 'started'

        expect(subject).to contain_exactly(iteration_from_project_2)
      end

      it 'filters by opened state' do
        params[:state] = 'opened'

        expect(subject).to contain_exactly(upcoming_group_iteration, iteration_from_project_2)
      end

      it 'filters by closed state' do
        params[:state] = 'closed'

        expect(subject).to contain_exactly(started_group_iteration, iteration_from_project_1)
      end

      it 'filters by title' do
        params[:title] = 'one test'

        expect(subject.to_a).to contain_exactly(started_group_iteration)
      end

      it 'filters by search_title' do
        params[:search_title] = 'one t'

        expect(subject.to_a).to contain_exactly(started_group_iteration)
      end

      it 'filters by ID' do
        params[:id] = iteration_from_project_1.id

        expect(subject).to contain_exactly(iteration_from_project_1)
      end

      it 'filters by cadence' do
        params[:iteration_cadence_ids] = iteration_cadence1.id

        expect(subject).to contain_exactly(upcoming_group_iteration)
      end

      it 'filters by multiple cadences' do
        params[:iteration_cadence_ids] = [iteration_cadence1.id, iteration_cadence2.id]

        expect(subject).to contain_exactly(started_group_iteration, upcoming_group_iteration)
      end

      context 'by timeframe' do
        it 'returns iterations with start_date and due_date between timeframe' do
          params.merge!(start_date: now - 1.day, end_date: 3.days.from_now)

          expect(subject).to match_array([started_group_iteration, upcoming_group_iteration, iteration_from_project_1])
        end

        it 'returns iterations which start before the timeframe' do
          iteration = create(:iteration, :skip_project_validation, :skip_future_date_validation, project: project_2, start_date: now - 5.days, due_date: now - 3.days)
          params.merge!(start_date: now - 3.days, end_date: now - 2.days)

          expect(subject).to match_array([iteration])
        end

        it 'returns iterations which end after the timeframe' do
          iteration = create(:iteration, :skip_project_validation, project: project_2, start_date: 9.days.from_now, due_date: 2.weeks.from_now)
          params.merge!(start_date: 9.days.from_now, end_date: 10.days.from_now)

          expect(subject).to match_array([iteration])
        end

        describe 'when one of the timeframe params are missing' do
          it 'does not filter by timeframe if start_date is missing' do
            only_end_date = described_class.new(user, params.merge(end_date: 1.year.ago)).execute

            expect(only_end_date).to eq(subject)
          end

          it 'does not filter by timeframe if end_date is missing' do
            only_start_date = described_class.new(user, params.merge(start_date: 1.year.from_now)).execute

            expect(only_start_date).to eq(subject)
          end
        end
      end
    end

    describe 'iid' do
      let(:params) do
        {
          project_ids: project_ids,
          group_ids: group.id,
          iid: iteration_from_project_1.iid
        }
      end

      it 'only accepts one of project_id or group_id' do
        expect { subject }.to raise_error(ArgumentError, 'You can specify only one scope if you use iid filter')
      end
    end

    describe '#find_by' do
      it 'finds a single iteration' do
        finder = described_class.new(user, project_ids: [project_1.id])

        expect(finder.find_by(iid: iteration_from_project_1.iid)).to eq(iteration_from_project_1)
      end
    end

    describe '.params_for_parent' do
      let_it_be(:parent_group) { create(:group) }
      let_it_be(:group) { create(:group, parent: parent_group) }
      let_it_be(:project) { create(:project, group: group) }

      context 'when parent is a project' do
        subject { described_class.params_for_parent(project, include_ancestors: include_ancestors) }

        context 'when include_ancestors is true' do
          let(:include_ancestors) { true }

          it 'returns project and ancestor group ids' do
            expect(subject).to match(group_ids: contain_exactly(group, parent_group), project_ids: project.id)
          end
        end

        context 'when include_ancestors is false' do
          let(:include_ancestors) { false }

          it 'returns project id' do
            expect(subject).to eq(project_ids: project.id)
          end
        end
      end

      context 'when parent is a group' do
        subject { described_class.params_for_parent(group, include_ancestors: include_ancestors) }

        context 'when include_ancestors is true' do
          let(:include_ancestors) { true }

          it 'returns group and ancestor ids' do
            expect(subject).to match(group_ids: contain_exactly(group, parent_group))
          end
        end

        context 'when include_ancestors is false' do
          let(:include_ancestors) { false }

          it 'returns group id' do
            expect(subject).to eq(group_ids: group.id)
          end
        end
      end

      context 'when parent is invalid' do
        subject { described_class.params_for_parent(double(User)) }

        it 'raises an ArgumentError' do
          expect { subject }.to raise_error(ArgumentError, 'Invalid parent class. Only Project and Group are supported.')
        end
      end
    end
  end
end
