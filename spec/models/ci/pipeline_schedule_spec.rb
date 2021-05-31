# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::PipelineSchedule do
  let_it_be(:project) { create_default(:project) }

  subject { build(:ci_pipeline_schedule) }

  it { is_expected.to belong_to(:project) }
  it { is_expected.to belong_to(:owner) }

  it { is_expected.to have_many(:pipelines) }
  it { is_expected.to have_many(:variables) }

  it { is_expected.to respond_to(:ref) }
  it { is_expected.to respond_to(:cron) }
  it { is_expected.to respond_to(:cron_timezone) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:next_run_at) }

  it_behaves_like 'includes Limitable concern' do
    subject { build(:ci_pipeline_schedule, project: project) }
  end

  describe 'validations' do
    it 'does not allow invalid cron patterns' do
      pipeline_schedule = build(:ci_pipeline_schedule, cron: '0 0 0 * *')

      expect(pipeline_schedule).not_to be_valid
    end

    it 'does not allow invalid cron patterns' do
      pipeline_schedule = build(:ci_pipeline_schedule, cron_timezone: 'invalid')

      expect(pipeline_schedule).not_to be_valid
    end

    context 'when active is false' do
      it 'does not allow nullified ref' do
        pipeline_schedule = build(:ci_pipeline_schedule, :inactive, ref: nil)

        expect(pipeline_schedule).not_to be_valid
      end
    end

    context 'when cron contains trailing whitespaces' do
      it 'strips the attribute' do
        pipeline_schedule = build(:ci_pipeline_schedule, cron: ' 0 0 * * *   ')

        expect(pipeline_schedule).to be_valid
        expect(pipeline_schedule.cron).to eq('0 0 * * *')
      end
    end
  end

  describe '.runnable_schedules' do
    subject { described_class.runnable_schedules }

    let!(:pipeline_schedule) do
      travel_to(1.day.ago) do
        create(:ci_pipeline_schedule, :hourly)
      end
    end

    it 'returns the runnable schedule' do
      is_expected.to eq([pipeline_schedule])
    end

    context 'when there are no runnable schedules' do
      let!(:pipeline_schedule) { }

      it 'returns an empty array' do
        is_expected.to be_empty
      end
    end
  end

  describe '.preloaded' do
    subject { described_class.preloaded }

    before do
      create_list(:ci_pipeline_schedule, 3)
    end

    it 'preloads the associations' do
      subject

      query = ActiveRecord::QueryRecorder.new { subject.map(&:project).each(&:route) }

      expect(query.count).to eq(3)
    end
  end

  describe '.owned_by' do
    let(:user) { create(:user) }
    let!(:owned_pipeline_schedule) { create(:ci_pipeline_schedule, owner: user) }
    let!(:other_pipeline_schedule) { create(:ci_pipeline_schedule) }

    subject { described_class.owned_by(user) }

    it 'returns owned pipeline schedules' do
      is_expected.to eq([owned_pipeline_schedule])
    end
  end

  describe '#set_next_run_at' do
    let(:pipeline_schedule_worker) {}
    let(:daily_pipeline_schedule_triggers) {}

    before do
      if pipeline_schedule_worker
        allow(Settings).to receive(:cron_jobs) do
          { 'pipeline_schedule_worker' => { 'cron' => pipeline_schedule_worker } }
        end
      end

      if daily_pipeline_schedule_triggers
        create(:plan_limits, :default_plan, daily_pipeline_schedule_triggers: daily_pipeline_schedule_triggers)
      end
    end

    context 'when PipelineScheduleWorker runs at a specific interval' do
      let(:pipeline_schedule) { create(:ci_pipeline_schedule, :nightly) }
      let(:pipeline_schedule_worker) { '0 1 2 3 *' }

      it "updates next_run_at to the sidekiq worker's execution time" do
        Timecop.freeze(2021, 1, 1, 10, 0) do
          check_pipeline_schedule(Time.zone.local(2021, 3, 2, 1, 0))
        end
      end
    end

    context 'when PipelineScheduleWorker runs every 5 minutes' do
      let(:pipeline_schedule_worker) { '*/5 * * * *' }

      context 'when the pipeline schedule wants to run every minute' do
        let(:pipeline_schedule) { create(:ci_pipeline_schedule, :every_minute) }

        it "updates next_run_at according to the worker cron", :aggregate_failures do
          Timecop.freeze(2021, 5, 27, 11, 20) do
            check_pipeline_schedule(Time.zone.local(2021, 5, 27, 11, 25))
          end
        end

        context 'when daily_pipeline_schedule_triggers limit is every 10 minutes' do
          let(:daily_pipeline_schedule_triggers) { 24 * 60 / 10 }

          it "updates next_run_at according to the plan", :aggregate_failures do
            Timecop.freeze(2021, 5, 27, 11, 20) do
              check_pipeline_schedule(Time.zone.local(2021, 5, 27, 11, 31))
            end

            Timecop.freeze(2021, 5, 27, 11, 30) do
              check_pipeline_schedule(Time.zone.local(2021, 5, 27, 11, 41))
            end
          end

          context 'when the FF ci_daily_limit_for_pipeline_schedules is disabled' do
            before do
              stub_feature_flags(ci_daily_limit_for_pipeline_schedules: false)
            end

            it "updates next_run_at according to the worker cron", :aggregate_failures do
              Timecop.freeze(2021, 5, 27, 11, 20) do
                check_pipeline_schedule(Time.zone.local(2021, 5, 27, 11, 25))
              end

              Timecop.freeze(2021, 5, 27, 11, 25) do
                check_pipeline_schedule(Time.zone.local(2021, 5, 27, 11, 30))
              end
            end
          end
        end
      end

      context 'when the pipeline schedule wants to run every hour' do
        let(:pipeline_schedule) { create(:ci_pipeline_schedule, cron: '0 * * * *') }

        it "updates next_run_at according to the worker cron", :aggregate_failures do
          Timecop.freeze(2021, 5, 27, 11, 20) do
            check_pipeline_schedule(Time.zone.local(2021, 5, 27, 12, 5))
          end

          Timecop.freeze(2021, 5, 27, 12, 0) do
            check_pipeline_schedule(Time.zone.local(2021, 5, 27, 13, 5))
          end
        end

        context 'when daily_pipeline_schedule_triggers limit is every 10 minutes' do
          let(:daily_pipeline_schedule_triggers) { 24 * 60 / 10 }

          it "updates next_run_at according to the plan", :aggregate_failures do
            Timecop.freeze(2021, 5, 27, 11, 20) do
              check_pipeline_schedule(Time.zone.local(2021, 5, 27, 12, 10))
            end

            Timecop.freeze(2021, 5, 27, 12, 0) do
              check_pipeline_schedule(Time.zone.local(2021, 5, 27, 13, 10))
            end
          end
        end

        context 'when daily_pipeline_schedule_triggers limit is every 5 minutes' do
          let(:daily_pipeline_schedule_triggers) { 24 * 60 / 5 }

          it "updates next_run_at according to the plan", :aggregate_failures do
            Timecop.freeze(2021, 5, 27, 11, 20) do
              check_pipeline_schedule(Time.zone.local(2021, 5, 27, 12, 5))
            end

            Timecop.freeze(2021, 5, 27, 12, 0) do
              check_pipeline_schedule(Time.zone.local(2021, 5, 27, 13, 5))
            end
          end
        end
      end
    end

    context 'when there are two different pipeline schedules in different time zones' do
      let(:pipeline_schedule_1) { create(:ci_pipeline_schedule, :weekly, cron_timezone: 'Eastern Time (US & Canada)') }
      let(:pipeline_schedule_2) { create(:ci_pipeline_schedule, :weekly, cron_timezone: 'UTC') }

      it 'sets different next_run_at' do
        expect(pipeline_schedule_1.next_run_at).not_to eq(pipeline_schedule_2.next_run_at)
      end
    end

    def check_pipeline_schedule(time)
      pipeline_schedule.set_next_run_at

      expect(pipeline_schedule.next_run_at.month).to eq(time.month)
      expect(pipeline_schedule.next_run_at.day).to eq(time.day)
      expect(pipeline_schedule.next_run_at.hour).to eq(time.hour)
      expect(pipeline_schedule.next_run_at.min).to eq(time.min)
    end
  end

  describe '#schedule_next_run!' do
    let!(:pipeline_schedule) { create(:ci_pipeline_schedule, :nightly) }

    before do
      pipeline_schedule.update_column(:next_run_at, nil)
    end

    it 'updates next_run_at' do
      expect { pipeline_schedule.schedule_next_run! }
        .to change { pipeline_schedule.next_run_at }
    end

    context 'when record is invalid' do
      before do
        allow(pipeline_schedule).to receive(:save!) { raise ActiveRecord::RecordInvalid, pipeline_schedule }
      end

      it 'nullifies the next run at' do
        pipeline_schedule.schedule_next_run!

        expect(pipeline_schedule.next_run_at).to be_nil
      end
    end
  end

  describe '#job_variables' do
    let!(:pipeline_schedule) { create(:ci_pipeline_schedule) }

    let!(:pipeline_schedule_variables) do
      create_list(:ci_pipeline_schedule_variable, 2, pipeline_schedule: pipeline_schedule)
    end

    subject { pipeline_schedule.job_variables }

    before do
      pipeline_schedule.reload
    end

    it { is_expected.to contain_exactly(*pipeline_schedule_variables.map(&:to_runner_variable)) }
  end
end
