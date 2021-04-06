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
    end
  end
end
