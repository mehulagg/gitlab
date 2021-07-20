# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ClearSharedRunnersMinutesWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    subject { worker.perform }

    context 'when ci_parallel_minutes_reset feature flag is disabled' do
      let(:namespace) { create(:namespace) }

      before do
        stub_feature_flags(ci_parallel_minutes_reset: false)

        expect_next_instance_of(described_class) do |instance|
          expect(instance).to receive(:try_obtain_lease).and_return(true)
        end
      end

      context 'when project statistics are defined' do
        let(:project) { create(:project, namespace: namespace) }
        let(:statistics) { project.statistics }

        before do
          statistics.update!(shared_runners_seconds: 100)
        end

        it 'clears counters' do
          subject

          expect(statistics.reload.shared_runners_seconds).to be_zero
        end

        it 'resets timer' do
          subject

          expect(statistics.reload.shared_runners_seconds_last_reset).to be_like_time(Time.current)
        end

        context 'when there are namespaces that were not reset after the reset steps' do
          let(:namespace_ids) { [namespace.id] }

          before do
            allow(Namespace).to receive(:each_batch).and_yield(Namespace.all)
            allow(Namespace).to receive(:transaction).and_raise(ActiveRecord::ActiveRecordError)
          end

          it 'raises an exception' do
            expect { worker.perform }.to raise_error(
              Ci::Minutes::BatchResetService::BatchNotResetError,
              'Some namespace shared runner minutes were not reset'
            )
          end
        end
      end

      context 'when namespace statistics are defined' do
        let!(:statistics) { create(:namespace_statistics, namespace: namespace, shared_runners_seconds: 100) }

        it 'clears counters' do
          subject

          expect(statistics.reload.shared_runners_seconds).to be_zero
        end

        it 'resets timer' do
          subject

          expect(statistics.reload.shared_runners_seconds_last_reset).to be_like_time(Time.current)
        end
      end

      context 'when namespace has extra shared runner minutes' do
        let!(:namespace) do
          create(:namespace, shared_runners_minutes_limit: 100, extra_shared_runners_minutes_limit: 10 )
        end

        let!(:statistics) do
          create(:namespace_statistics, namespace: namespace, shared_runners_seconds: minutes_used * 60)
        end

        let(:minutes_used) { 0 }

        context 'when consumption is below the default quota' do
          let(:minutes_used) { 50 }

          it 'does not modify the extra minutes quota' do
            subject

            expect(namespace.reload.extra_shared_runners_minutes_limit).to eq(10)
          end
        end

        context 'when consumption is above the default quota' do
          context 'when all extra minutes are used' do
            let(:minutes_used) { 115 }

            it 'sets extra minutes to 0' do
              subject

              expect(namespace.reload.extra_shared_runners_minutes_limit).to eq(0)
            end
          end

          context 'when some extra minutes are used' do
            let(:minutes_used) { 105 }

            it 'discounts the extra minutes used' do
              subject

              expect(namespace.reload.extra_shared_runners_minutes_limit).to eq(5)
            end
          end
        end

        [:last_ci_minutes_notification_at, :last_ci_minutes_usage_notification_level].each do |attr|
          context "when #{attr} is present" do
            before do
              namespace.update_attribute(attr, Time.current)
            end

            it 'nullifies the field' do
              expect(namespace.send(attr)).to be_present

              subject

              expect(namespace.reload.send(attr)).not_to be_present
            end
          end
        end
      end
    end

    context 'when ci_parallel_minutes_reset feature flag is enabled' do
      subject { worker.perform }

      before do
        stub_feature_flags(ci_parallel_minutes_reset: true)

        [2, 3, 4, 5, 7, 8, 10, 14].each do |id|
          create(:namespace, id: id)
        end
      end

      context 'with batch size lower than count of namespaces' do
        before do
          stub_const("#{described_class}::BATCH_SIZE", 3)
        end

        it 'runs a worker per batch', :aggregate_failures do
          # Spreads evenly accross 8 hours (28,800 seconds)
          expect(Ci::BatchResetMinutesWorker).to receive(:perform_in).with(0.seconds, 2, 4)
          expect(Ci::BatchResetMinutesWorker).to receive(:perform_in).with(7200.seconds, 5, 7)
          expect(Ci::BatchResetMinutesWorker).to receive(:perform_in).with(14400.seconds, 8, 10)
          expect(Ci::BatchResetMinutesWorker).to receive(:perform_in).with(21600.seconds, 11, 13)
          expect(Ci::BatchResetMinutesWorker).to receive(:perform_in).with(28800.seconds, 14, 16)

          subject
        end
      end

      context 'with batch size higher than count of namespaces' do
        # Uses default BATCH_SIZE
        it 'runs the worker in a single batch', :aggregate_failures do
          # Runs a single batch, immediately
          expect(Ci::BatchResetMinutesWorker).to receive(:perform_in).with(0.seconds, 2, 100001)

          subject
        end
      end
    end
  end
end
