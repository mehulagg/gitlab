# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SeatLinkData do
  subject do
    described_class.new(
      timestamp: timestamp,
      key: key,
      max_users: max_users,
      active_users: active_users
    )
  end

  let_it_be(:timestamp) { Time.iso8601('2020-03-22T06:09:18Z') }
  let_it_be(:key) { 'key' }
  let_it_be(:max_users) { 11 }
  let_it_be(:active_users) { 5 }

  describe '#initialize' do
    let_it_be(:utc_time) { Time.utc(2020, 3, 12, 12, 00) }
    let_it_be(:license_start_date) { utc_time.to_date - 1.month }
    let_it_be(:current_license) { create_current_license(starts_at: license_start_date)}

    let_it_be(:max_before_today) { 15 }
    let_it_be(:yesterday_active_count) { 12 }
    let_it_be(:today_active_count) { 20 }

    before_all do
      create(:historical_data, recorded_at: license_start_date, active_user_count: 10)
      create(:historical_data, recorded_at: license_start_date + 1.day, active_user_count: max_before_today)
      create(:historical_data, recorded_at: utc_time - 1.day, active_user_count: yesterday_active_count)
      create(:historical_data, recorded_at: utc_time, active_user_count: today_active_count)
    end

    around do |example|
      travel_to(utc_time) { example.run }
    end

    context 'when passing no params' do
      subject { described_class.new }

      it 'returns object with default attributes set' do
        expect(subject).to have_attributes(
          timestamp: eq(utc_time),
          key: eq(current_license.data),
          max_users: eq(today_active_count),
          active_users: eq(today_active_count)
        )
      end
    end

    context 'when passing params' do
      it 'returns object with given attributes set' do
        expect(subject).to have_attributes(
          timestamp: eq(timestamp),
          key: eq(key),
          max_users: eq(max_users),
          active_users: eq(active_users)
        )
      end

      context 'when passing date param only' do
        subject { described_class.new(timestamp: utc_time - 1.day) }

        it 'returns object with attributes set using given date' do
          expect(subject).to have_attributes(
            timestamp: eq(utc_time - 1.day),
            key: eq(current_license.data),
            max_users: eq(max_before_today),
            active_users: eq(yesterday_active_count)
          )
        end
      end
    end
  end

  describe '.to_json' do
    it { is_expected.to delegate_method(:to_json).to(:data) }

    it 'returns payload data as a JSON string' do
      expect(subject.to_json).to eq(
        {
          timestamp: timestamp.iso8601,
          date: timestamp.to_date.iso8601,
          license_key: key,
          max_historical_user_count: max_users,
          active_users: active_users
        }.to_json
      )
    end
  end

  describe '#sync' do
    before do
      allow(subject).to receive(:should_sync_seats?).and_return(sync_seats)
    end

    context 'when ready to sync seats' do
      let(:sync_seats) { true }

      it 'performs the sync' do
        expect(SyncSeatLinkWorker).to receive(:perform_async)

        subject.sync
      end
    end

    context 'when not ready to sync seats' do
      let(:sync_seats) { false }

      it 'does not perform the sync' do
        expect(SyncSeatLinkWorker).not_to receive(:perform_async)

        subject.sync
      end
    end
  end

  describe '#should_sync_seats?' do
    let_it_be(:historical_data) { create(:historical_data, recorded_at: timestamp) }

    let(:license) { build(:license, :cloud) }

    before do
      allow(License).to receive(:current).and_return(license)
    end

    subject { super().should_sync_seats? }

    context 'when all the pre conditions are valid' do
      it { is_expected.to eq(true) }
    end

    context 'when license key is missing' do
      let(:license) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when expires_at is not set' do
      let(:license) { build(:license, expires_at: nil) }

      it { is_expected.to be_falsey }
    end

    context 'cloud license' do
      context 'when license is trial' do
        let(:license) { build(:license, trial: true) }

        it { is_expected.to be_falsey }
      end

      context 'when timestamp is out of the range' do
        let(:timestamp) { license.starts_at - 1.day }

        it { is_expected.to be_falsey }
      end

      context 'when historical data not found' do
        before do
          historical_data.destroy!
        end

        it { is_expected.to eq(true) }
      end
    end

    context 'legacy license' do
      let(:license) { build(:license) }

      context 'when seat link is disabled' do
        before do
          allow(Settings.gitlab).to receive(:seat_link_enabled).and_return(false)
        end

        it { is_expected.to be_falsey }
      end

      context 'when license is trial' do
        let(:license) { build(:license, trial: true) }

        it { is_expected.to be_falsey }
      end

      context 'when timestamp is out of the range' do
        let(:timestamp) { license.starts_at - 1.day }

        it { is_expected.to be_falsey }
      end

      context 'when historical data not found' do
        before do
          historical_data.destroy!
        end

        it { is_expected.to eq(false) }
      end
    end
  end
end
