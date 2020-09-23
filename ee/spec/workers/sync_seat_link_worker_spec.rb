# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SyncSeatLinkWorker, type: :worker do
  describe '#perform' do
    context 'when current, paid license is active' do
      let(:utc_time) { Time.utc(2020, 3, 12, 12, 00) }

      before do
        # Setting the date as 12th March 2020 12:00 UTC for tests and creating new license
        create_current_license(starts_at: '2020-02-12'.to_date)

        HistoricalData.create!(date: '2020-02-11'.to_date, active_user_count: 100)
        HistoricalData.create!(date: '2020-02-12'.to_date, active_user_count: 10)
        HistoricalData.create!(date: '2020-02-13'.to_date, active_user_count: 15)

        HistoricalData.create!(date: '2020-03-11'.to_date, active_user_count: 10)
        HistoricalData.create!(date: '2020-03-12'.to_date, active_user_count: 20)
        HistoricalData.create!(date: '2020-03-15'.to_date, active_user_count: 25)
        allow(SyncSeatLinkRequestWorker).to receive(:perform_async).and_return(true)
      end

      it 'executes the SyncSeatLinkRequestWorker with expected params' do
        Timecop.travel(utc_time) do
          subject.perform

          expect(SyncSeatLinkRequestWorker).to have_received(:perform_async)
            .with(
              '2020-03-11',
              License.current.data,
              15,
              10
            )
        end
      end

      context 'when the timezone makes date one day in advance' do
        around do |example|
          Time.use_zone('Auckland') { example.run }
        end

        it 'executes the SyncSeatLinkRequestWorker with expected params' do
          Timecop.travel(utc_time) do
            expect(Date.current.to_s).to eql('2020-03-13')

            subject.perform

            expect(SyncSeatLinkRequestWorker).to have_received(:perform_async)
              .with(
                '2020-03-11',
                License.current.data,
                15,
                10
              )
          end
        end

        context 'when the timezone makes date one day before than UTC' do
          around do |example|
            Time.use_zone('Central America') { example.run }
          end

          it 'executes the SyncSeatLinkRequestWorker with expected params' do
            Timecop.travel(utc_time.beginning_of_day) do
              expect(Date.current.to_s).to eql('2020-03-11')

              subject.perform

              expect(SyncSeatLinkRequestWorker).to have_received(:perform_async)
                .with(
                  '2020-03-11',
                  License.current.data,
                  15,
                  10
                )
            end
          end
        end
      end
    end

    shared_examples 'no seat link sync' do
      it 'does not execute the SyncSeatLinkRequestWorker' do
        expect(SyncSeatLinkRequestWorker).not_to receive(:perform_async)

        subject.perform
      end
    end

    context 'when license is missing' do
      before do
        License.current.destroy!
      end

      include_examples 'no seat link sync'
    end

    context 'when using a trial license' do
      before do
        create(:license, trial: true)
      end

      include_examples 'no seat link sync'
    end

    context 'when the license has no expiration date' do
      before do
        create_current_license(expires_at: nil, block_changes_at: nil)
      end

      include_examples 'no seat link sync'
    end

    context 'when using an expired license' do
      before do
        create_current_license(expires_at: expiration_date)
      end

      context 'the license expired over 15 days ago' do
        let(:expiration_date) { Time.now.utc.to_date - 16.days }

        include_examples 'no seat link sync'
      end

      context 'the license expired less than or equal to 15 days ago' do
        let(:expiration_date) { Time.now.utc.to_date - 15.days }

        it 'executes the SyncSeatLinkRequestWorker' do
          expect(SyncSeatLinkRequestWorker).to receive(:perform_async).and_return(true)

          subject.perform
        end
      end
    end

    context 'when seat link has been disabled' do
      before do
        allow(Gitlab::CurrentSettings).to receive(:seat_link_enabled?).and_return(false)
      end

      include_examples 'no seat link sync'
    end
  end
end
