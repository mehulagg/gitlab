# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IterationsFinder do
  let(:now) { Time.now }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:project_1) { create(:project, namespace: group) }
  let_it_be(:project_2) { create(:project, namespace: group) }
  let_it_be(:user) { create(:user) }
  let!(:started_group_iteration) { create(:started_iteration, :skip_future_date_validation, group: group, title: 'one test', start_date: now - 1.day, due_date: now) }
  let!(:upcoming_group_iteration) { create(:iteration, group: group, start_date: 1.day.from_now, due_date: 2.days.from_now) }
  let!(:iteration_from_project_1) { create(:started_iteration, :skip_project_validation, project: project_1, start_date: 3.days.from_now, due_date: 4.days.from_now) }
  let!(:iteration_from_project_2) { create(:started_iteration, :skip_project_validation, project: project_2, start_date: 5.days.from_now, due_date: 6.days.from_now) }
  let(:project_ids) { [project_1.id, project_2.id] }

  subject { described_class.new(user, params).execute }

  context 'without permissions' do
    context 'groups and projects' do
      let(:params) { { project_ids: project_ids, group_ids: group.id, state: 'all' } }

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
      let(:params) { { project_ids: project_ids, state: 'all' } }

      it 'returns iterations for projects' do
        expect(subject).to contain_exactly(iteration_from_project_1, iteration_from_project_2)
      end
    end

    context 'iterations for groups' do
      let(:params) { { group_ids: group.id, state: 'all' } }

      it 'returns iterations for groups' do
        expect(subject).to contain_exactly(started_group_iteration, upcoming_group_iteration)
      end
    end

    context 'iterations for groups and project' do
      let(:params) { { project_ids: project_ids, group_ids: group.id, state: 'all' } }

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
          group_ids: group.id,
          state: 'all'
        }
      end

      before do
        started_group_iteration.close
        iteration_from_project_1.close
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
        finder = described_class.new(user, project_ids: [project_1.id], state: 'all')

        expect(finder.find_by(iid: iteration_from_project_1.iid)).to eq(iteration_from_project_1)
      end
    end
  end
end
