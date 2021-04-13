# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::API::Helpers::Runner do
  let(:helper) { Class.new { include API::Helpers::Runner }.new }

  before do
    allow(helper).to receive(:env).and_return({})
  end

  describe '#current_job' do
    let(:build) { create(:ci_build, :running) }

    it 'handles sticking of a build when a build ID is specified' do
      allow(helper).to receive(:params).and_return(id: build.id)

      expect(Gitlab::Database::LoadBalancing::RackMiddleware)
        .to receive(:stick_or_unstick)
        .with({}, :build, build.id)

      helper.current_job
    end

    it 'does not handle sticking if no build ID was specified' do
      allow(helper).to receive(:params).and_return({})

      expect(Gitlab::Database::LoadBalancing::RackMiddleware)
        .not_to receive(:stick_or_unstick)

      helper.current_job
    end

    it 'returns the build if one could be found' do
      allow(helper).to receive(:params).and_return(id: build.id)

      expect(helper.current_job).to eq(build)
    end
  end

  describe '#current_runner' do
    let(:runner) { create(:ci_runner, token: 'foo') }

    it 'handles sticking of a runner if a token is specified' do
      allow(helper).to receive(:params).and_return(token: runner.token)

      expect(Gitlab::Database::LoadBalancing::RackMiddleware)
        .to receive(:stick_or_unstick)
        .with({}, :runner, runner.token)

      helper.current_runner
    end

    it 'does not handle sticking if no token was specified' do
      allow(helper).to receive(:params).and_return({})

      expect(Gitlab::Database::LoadBalancing::RackMiddleware)
        .not_to receive(:stick_or_unstick)

      helper.current_runner
    end

    it 'returns the runner if one could be found' do
      allow(helper).to receive(:params).and_return(token: runner.token)

      expect(helper.current_runner).to eq(runner)
    end
  end

  describe '#track_ci_minutes_usage' do
    let!(:build) { create(:ci_build, build_status) }
    let!(:runner) { create(:ci_runner, runner_type) }
    let(:build_status) { :running }
    let(:runner_type) { :instance }

    subject { helper.track_ci_minutes_usage(build, runner) }

    context 'when build is running' do
      context 'when runner is instance type' do
        it 'calls the service' do
          service = double(execute: nil)
          expect(::Ci::Minutes::TrackLiveConsumptionService).to receive(:new).and_return(service)

          subject
        end
      end

      context 'when runner is not instance type' do
        let(:runner_type) { :project }

        it 'does not do anything' do
          expect(::Ci::Minutes::TrackLiveConsumptionService).not_to receive(:new)

          subject
        end
      end
    end

    context 'when build is not running' do
      let(:build_status) { :success }

      it 'does not do anything' do
        expect(::Ci::Minutes::TrackLiveConsumptionService).not_to receive(:new)

        subject
      end
    end
  end
end
