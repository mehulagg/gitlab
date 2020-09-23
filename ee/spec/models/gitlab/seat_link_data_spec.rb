# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SeatLinkData do
  subject do
    described_class.new(
      date: date,
      key: key,
      max_users: max_users,
      active_users: active_users
    )
  end

  let_it_be(:date) { '2020-03-22'.to_date }
  let_it_be(:key) { 'key' }
  let_it_be(:max_users) { 11 }
  let_it_be(:active_users) { 5 }

  describe '#initialize' do
    let_it_be(:utc_time) { Time.utc(2020, 3, 12, 12, 00) }
    let_it_be(:utc_date) { utc_time.to_date }
    let_it_be(:license_start_date) { utc_date - 1.month }
    let_it_be(:current_license) { create_current_license(starts_at: license_start_date)}

    let_it_be(:max_before_today) { 15 }
    let_it_be(:yesterday_active_count) { 12 }
    let_it_be(:today_active_count) { 20 }

    before_all do
      HistoricalData.create!(date: license_start_date, active_user_count: 10)
      HistoricalData.create!(date: license_start_date + 1.day, active_user_count: max_before_today)
      HistoricalData.create!(date: utc_date - 1.day, active_user_count: yesterday_active_count)
      HistoricalData.create!(date: utc_date, active_user_count: today_active_count)
    end

    around do |example|
      Timecop.travel(utc_time) { example.run }
    end

    context 'when passing no params' do
      subject { described_class.new }

      it 'returns object with default attributes set' do
        expect(subject).to have_attributes(
          date: eq(utc_date - 1.day),
          key: eq(current_license.data),
          max_users: eq(max_before_today),
          active_users: eq(yesterday_active_count)
        )
      end
    end

    context 'when passing params' do
      it 'returns object with given attributes set' do
        expect(subject).to have_attributes(
          date: eq(date),
          key: eq(key),
          max_users: eq(max_users),
          active_users: eq(active_users)
        )
      end

      context 'when passing date param only' do
        subject { described_class.new(date: utc_date) }

        it 'returns object with attributes set using given date' do
          expect(subject).to have_attributes(
            date: eq(utc_date),
            key: eq(current_license.data),
            max_users: eq(today_active_count),
            active_users: eq(today_active_count)
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
          date: date.to_s,
          license_key: key,
          max_historical_user_count: max_users,
          active_users: active_users
        }.to_json
      )
    end
  end
end
