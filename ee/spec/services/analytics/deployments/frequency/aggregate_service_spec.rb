# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::Deployments::Frequency::AggregateService do
  let_it_be(:group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: group) }
  let_it_be(:group_project, refind: true) { create(:project, :repository, group: group) }
  let_it_be(:subgroup_project, refind: true) { create(:project, :repository, group: subgroup) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:guest) { create(:user) }

  let(:container) { group_project }
  let(:actor) { developer }
  let(:service) { described_class.new(container: container, current_user: actor, params: params) }
  let(:params) { { from: 4.days.ago.to_datetime } }

  before_all do
    group.add_developer(developer)
    group.add_guest(guest)
  end

  before do
    stub_licensed_features(dora4_analytics: true)
  end

  around do |example|
    freeze_time { example.run }
  end

  describe '#execute' do
    subject { service.execute }

    let_it_be(:group_production) { create(:environment, project: group_project, name: 'production') }
    let_it_be(:group_staging) { create(:environment, project: group_project, name: 'staging') }
    let_it_be(:subgroup_production) { create(:environment, project: subgroup_project, name: 'production') }
    let_it_be(:subgroup_staging) { create(:environment, project: subgroup_project, name: 'staging') }

    before_all do
      create(:deployment, :success, project: group_project, environment: group_production, finished_at: 7.days.ago)
      create(:deployment, :failed,  project: group_project, environment: group_production, finished_at: 3.days.ago)
      create(:deployment, :success, project: group_project, environment: group_production, finished_at: 1.day.ago)
      create(:deployment, :success, project: group_project, environment: group_staging,    finished_at: 1.day.ago)

      create(:deployment, :success, project: subgroup_project, environment: subgroup_production, finished_at: 7.days.ago)
      create(:deployment, :failed,  project: subgroup_project, environment: subgroup_production, finished_at: 3.days.ago)
      create(:deployment, :success, project: subgroup_project, environment: subgroup_production, finished_at: 1.day.ago)
      create(:deployment, :success, project: subgroup_project, environment: subgroup_staging,    finished_at: 1.day.ago)
    end

    shared_examples_for 'validation error' do
      it 'returns an error with message' do
        result = subject

        expect(result[:status]).to eq(:error)
        expect(result[:message]).to eq(message)
      end
    end

    it 'returns deployment frequencies' do
      result = subject

      expect(result[:status]).to eq(:success)
      expect(result[:frequencies]).to eq(
        [
          {
            from: params[:from],
            to: DateTime.current,
            value: 2
          }
        ]
      )
    end

    context 'when date range is specified' do
      let(:params) { { from: 10.days.ago.to_datetime, to: 5.days.from_now.to_datetime } }

      it 'returns deployment frequencies' do
        result = subject

        expect(result[:status]).to eq(:success)
        expect(result[:frequencies]).to eq(
          [
            {
              from: params[:from],
              to: params[:to],
              value: 3
            }
          ]
        )
      end
    end

    context 'when environment name is specified' do
      let(:params) { { from: 3.days.ago.to_datetime, environment: 'production' } }

      it 'returns frequencies that related to production environment' do
        result = subject

        expect(result[:status]).to eq(:success)
        expect(result[:frequencies]).to eq(
          [
            {
              from: params[:from],
              to: DateTime.current,
              value: 1
            }
          ]
        )
      end
    end

    context 'when the container is group' do
      let(:container) { group }

      it 'returns frequencies that related to production environment' do
        result = subject

        expect(result[:status]).to eq(:success)
        expect(result[:frequencies]).to eq(
          [
            {
              from: params[:from],
              to: DateTime.current,
              value: 4
            }
          ]
        )
      end
    end

    context 'when parameter is empty' do
      let(:params) { {} }

      it_behaves_like 'validation error' do
        let(:message) { 'Parameter `from` must be specified' }
      end
    end

    context 'when start_date is eariler than end_date' do
      let(:params) { { from: 3.days.ago.to_datetime, to: 4.days.ago.to_datetime } }

      it_behaves_like 'validation error' do
        let(:message) { 'Parameter `to` is before the `from` date' }
      end
    end

    context 'when the date range is too broad' do
      let(:params) { { from: 1.year.ago.to_datetime } }

      it_behaves_like 'validation error' do
        let(:message) { 'Date range is greater than 91 days' }
      end
    end

    context 'when the interval is not supported' do
      let(:params) { { from: 3.days.ago.to_datetime, interval: 'unknown' } }

      it_behaves_like 'validation error' do
        let(:message) { 'Parameter `interval` must be one of ("all", "monthly", "daily")' }
      end
    end

    context 'when the actor does not have permission to read DORA4 metrics' do
      let(:actor) { guest }

      it_behaves_like 'validation error' do
        let(:message) { 'You do not have permission to access deployment frequencies' }
      end
    end

    context 'when license is insufficient' do
      before do
        stub_licensed_features(dora4_analytics: false)
      end

      it_behaves_like 'validation error' do
        let(:message) { 'You do not have permission to access deployment frequencies' }
      end
    end
  end
end
