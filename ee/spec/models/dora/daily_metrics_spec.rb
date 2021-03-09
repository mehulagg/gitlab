# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dora::DailyMetrics, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:environment) }
  end

  describe '.refresh!' do
    subject { described_class.refresh!(environment, date) }

    around do |example|
      freeze_time { example.run }
    end

    let_it_be(:project) { create(:project, :repository) }
    let_it_be(:environment) { create(:environment, project: project) }
    let(:date) { 1.day.ago.to_date }

    context 'with finished deployments' do
      before do
        # Deployment finished before the date
        previous_date = date - 1.day
        create(:deployment, :success, environment: environment, finished_at: previous_date)
        create(:deployment, :failed, environment: environment, finished_at: previous_date)

        # Deployment finished on the date
        create(:deployment, :success, environment: environment, finished_at: date)
        create(:deployment, :failed, environment: environment, finished_at: date)

        # Deployment finished after the date
        next_date = date + 1.day
        create(:deployment, :success, environment: environment, finished_at: next_date)
        create(:deployment, :failed, environment: environment, finished_at: next_date)
      end

      it 'inserts the daily metrics' do
        expect { subject }.to change { Dora::DailyMetrics.count }.by(1)

        metrics = environment.dora_daily_metrics.find_by_date(date)
        expect(metrics.deployment_frequency).to eq(1)
        expect(metrics.lead_time_for_changes_in_seconds).to be_nil
      end

      context 'when there is an existing daily metric' do
        before do
          create(:dora_daily_metrics, environment: environment, date: date, deployment_frequency: 0)
        end

        it 'updates the daily metrics' do
          expect { subject }.not_to change { Dora::DailyMetrics.count }

          metrics = environment.dora_daily_metrics.find_by_date(date)
          expect(metrics.deployment_frequency).to eq(1)
        end
      end
    end

    context 'with finished deployments and merged MRs' do
      before do
        merge_requests = []

        # Merged 1 day ago
        merge_requests << create(:merge_request, :with_merged_metrics, project: project).tap do |merge_request|
          merge_request.metrics.update!(merged_at: date - 1.day)
        end

        # Merged 2 days ago
        merge_requests << create(:merge_request, :with_merged_metrics, project: project).tap do |merge_request|
          merge_request.metrics.update!(merged_at: date - 2.days)
        end

        # Merged 3 days ago
        merge_requests << create(:merge_request, :with_merged_metrics, project: project).tap do |merge_request|
          merge_request.metrics.update!(merged_at: date - 3.days)
        end

        # Deployment finished on the date
        create(:deployment, :success, environment: environment, finished_at: date, merge_requests: merge_requests)
      end

      it 'inserts the daily metrics' do
        subject

        metrics = environment.dora_daily_metrics.find_by_date(date)
        expect(metrics.lead_time_for_changes_in_seconds).to eq(2.days.to_i) # median
      end

      context 'when there is an existing daily metric' do
        let!(:dora_daily_metrics) { create(:dora_daily_metrics, environment: environment, date: date, lead_time_for_changes_in_seconds: nil) }

        it 'updates the daily metrics' do
          expect { subject }
            .to change { dora_daily_metrics.reload.lead_time_for_changes_in_seconds }
            .from(nil)
            .to(2.days.to_i)
        end
      end
    end

    context 'when date is invalid type' do
      let(:date) { '2021-02-03' }

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
