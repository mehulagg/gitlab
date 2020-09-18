# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HistoricalDataWorker do
  subject { described_class.new }

  shared_examples 'not approaching active user count threshold' do
    it 'does not validate active user count' do
      expect(HistoricalData).not_to receive(:send_email_reminder_if_approaching_user_limit!)

      subject.perform
    end
  end

  describe '#perform' do
    context 'with a trial license' do
      before do
        FactoryBot.create(:license, trial: true)
      end

      it 'does not track historical data' do
        expect(HistoricalData).not_to receive(:track!)

        subject.perform
      end

      it_behaves_like 'not approaching active user count threshold'
    end

    context 'with a non trial license' do
      before do
        FactoryBot.create(:license)
      end

      it 'tracks historical data' do
        expect(HistoricalData).to receive(:track!)

        subject.perform
      end

      it 'validates active user count' do
        expect(HistoricalData).to receive(:send_email_reminder_if_approaching_user_limit!)

        subject.perform
      end
    end

    context 'when there is no a license key' do
      before do
        License.destroy_all # rubocop: disable Cop/DestroyAll
      end

      it 'does not track historical data' do
        expect(HistoricalData).not_to receive(:track!)

        subject.perform
      end

      it_behaves_like 'not approaching active user count threshold'
    end
  end
end
