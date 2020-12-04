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
      HistoricalData.create!(recorded_at: license_start_date, active_user_count: 10)
      HistoricalData.create!(recorded_at: license_start_date + 1.day, active_user_count: max_before_today)
      HistoricalData.create!(recorded_at: utc_time - 1.day, active_user_count: yesterday_active_count)
      HistoricalData.create!(recorded_at: utc_time, active_user_count: today_active_count)
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

  describe '#historical_data_exists?' do
    let_it_be(:license) { create_current_license(starts_at: Date.current - 7.days) }

    it 'returns false if no historical data exists' do
      expect(described_class.new.historical_data_exists?).to be(false)
    end

    it 'returns false if no historical data exists within [license start date, seat_link_data.date]' do
      create(:historical_data, recorded_at: Time.current - 8.days)
      create(:historical_data, recorded_at: Time.current)

      expect(described_class.new(timestamp: Time.current - 1.day).historical_data_exists?).to be(false)
    end

    it 'returns true if historical data exists within [license start date, seat_link_data.date]' do
      create(:historical_data, recorded_at: Time.current - 2.days)

      expect(described_class.new(timestamp: Time.current - 1.day).historical_data_exists?).to be(true)
    end
  end
end
