# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Metrics::Samplers::SidekiqSampler do
  let(:sampler) { described_class.new }

  it_behaves_like 'metrics sampler', 'SIDEKIQ_SAMPLER'

  describe '#sample' do
    let(:queues) { %w[q1 q2] }
    let(:jobs) { [[], []] }

    before do
      stub_redis :sscan_each, 'queues', queues
      stub_redis :pipelined, no_args, jobs
    end

    describe 'sampler duration' do
      it 'reports the sampling duration in seconds' do
        expect(sampler.metrics[:sampler_duration]).to receive(:increment).with({}, a_value > 0)

        sampler.sample
      end
    end

    describe 'sidekiq_queue_size' do
      context 'when queues are empty' do
        it 'reports queue size of 0' do
          queues.each do |q|
            expect(sampler.metrics[:sidekiq_queue_size]).to receive(:set).with({ name: q, queue: q }, 0)
          end

          sampler.sample
        end
      end

      context 'when there are jobs queued' do
        let(:job_json) do
          "{\"queue\":\"cronjob:update_all_mirrors\",\"args\":[],\"class\":\"UpdateAllMirrorsWorker\",\"retry\":false,\"backtrace\":true,\"version\":0,\"queue_namespace\":\"cronjob\",\"jid\":\"110eea53e1cecfaa5dd8dd01\",\"created_at\":1609430764.173322,\"meta.caller_id\":\"Cronjob\",\"correlation_id\":\"54f1595deb9c51e66468fd1b8ceed762\",\"enqueued_at\":1609430764.8751845,\"interrupted_count\":1}"
        end

        let(:jobs) { [[job_json], [job_json, job_json]] }

        it 'reports number of jobs as queue size' do
          expect(sampler.metrics[:sidekiq_queue_size]).to receive(:set).with({ name: 'q1', queue: 'q1' }, 1)
          expect(sampler.metrics[:sidekiq_queue_size]).to receive(:set).with({ name: 'q2', queue: 'q2' }, 2)

          sampler.sample
        end
      end
    end

    describe 'sidekiq_queue_latency' do
      context 'when queues are empty' do
        let(:jobs) { [[], []] }

        it 'reports queue latency of 0' do
          queues.each do |q|
            expect(sampler.metrics[:sidekiq_queue_latency]).to receive(:set).with({ name: q, queue: q }, 0)
          end

          sampler.sample
        end
      end

      context 'when there are jobs queued' do
        let(:now) { Time.current }
        let(:job1_enqueued_at) { (now - 2.seconds).to_i }
        let(:job1_json) do
          "{\"queue\":\"cronjob:update_all_mirrors\",\"args\":[],\"class\":\"UpdateAllMirrorsWorker\",\"retry\":false,\"backtrace\":true,\"version\":0,\"queue_namespace\":\"cronjob\",\"jid\":\"110eea53e1cecfaa5dd8dd01\",\"created_at\":1609430764.173322,\"meta.caller_id\":\"Cronjob\",\"correlation_id\":\"54f1595deb9c51e66468fd1b8ceed762\",\"enqueued_at\":#{job1_enqueued_at},\"interrupted_count\":1}"
        end

        let(:job2_enqueued_at) { (now - 1.second).to_i }
        let(:job2_json) do
          "{\"queue\":\"cronjob:update_all_mirrors\",\"args\":[],\"class\":\"UpdateAllMirrorsWorker\",\"retry\":false,\"backtrace\":true,\"version\":0,\"queue_namespace\":\"cronjob\",\"jid\":\"110eea53e1cecfaa5dd8dd01\",\"created_at\":1609430764.173322,\"meta.caller_id\":\"Cronjob\",\"correlation_id\":\"54f1595deb9c51e66468fd1b8ceed762\",\"enqueued_at\":#{job2_enqueued_at},\"interrupted_count\":1}"
        end

        let(:jobs) { [[job1_json], [job1_json, job2_json]] }

        it 'reports oldest job as queue latency in seconds' do
          # We can't use freeze_time because jobs are evaluated in a before block.
          travel_to(now) do
            expect(sampler.metrics[:sidekiq_queue_latency]).to receive(:set).with({ name: 'q1', queue: 'q1' }, 2)
            expect(sampler.metrics[:sidekiq_queue_latency]).to receive(:set).with({ name: 'q2', queue: 'q2' }, 2)

            sampler.sample
          end
        end
      end
    end
  end

  def stub_redis(cmd, args, result)
    Sidekiq.redis do |conn|
      allow(conn).to receive(cmd).with(args).and_return(result)
    end
  end
end
