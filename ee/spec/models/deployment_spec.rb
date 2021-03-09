# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Deployment do
  describe 'state machine' do
    context 'when deployment succeeded' do
      let(:deployment) { create(:deployment, :running) }

      it 'schedules Dora::DailyMetrics::RefreshWorker' do
        freeze_time do
          expect(::Dora::DailyMetrics::RefreshWorker)
            .to receive(:perform_in).with(
              5.minutes,
              deployment.environment_id,
              Time.current.to_date.to_s)

          deployment.succeed!
        end
      end

      context 'when dora_daily_metrics feature flag is disabled' do
        before do
          stub_feature_flags(dora_daily_metrics: false)
        end

        it 'does not schedule Dora::DailyMetrics::RefreshWorker' do
          expect(::Dora::DailyMetrics::RefreshWorker).not_to receive(:perform_in)

          deployment.succeed!
        end
      end
    end
  end
end
