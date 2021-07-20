# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TimeZoneHelper, :aggregate_failures do
  describe '#timezone_data' do
    context 'with short format' do
      subject(:timezone_data) { helper.timezone_data }

      it 'matches schema' do
        expect(timezone_data).not_to be_empty

        timezone_data.each_with_index do |timezone_hash, i|
          expect(timezone_hash.keys).to contain_exactly(
            :identifier,
            :name,
            :offset
          ), "Failed at index #{i}"
        end
      end

      it 'formats for display' do
        tz = ActiveSupport::TimeZone.all[0]

        expect(timezone_data[0]).to eq(
          identifier: tz.tzinfo.identifier,
          name: tz.name,
          offset: tz.now.utc_offset
        )
      end
    end

    context 'with full format' do
      subject(:timezone_data) { helper.timezone_data(format: :full) }

      it 'matches schema' do
        expect(timezone_data).not_to be_empty

        timezone_data.each_with_index do |timezone_hash, i|
          expect(timezone_hash.keys).to contain_exactly(
            :identifier,
            :name,
            :abbr,
            :offset,
            :formatted_offset
          ), "Failed at index #{i}"
        end
      end

      it 'formats for display' do
        tz = ActiveSupport::TimeZone.all[0]

        expect(timezone_data[0]).to eq(
          identifier: tz.tzinfo.identifier,
          name: tz.name,
          abbr: tz.tzinfo.strftime('%Z'),
          offset: tz.now.utc_offset,
          formatted_offset: tz.now.formatted_offset
        )
      end
    end

    context 'with unknown format' do
      subject(:timezone_data) { helper.timezone_data(format: :unknown) }

      it 'raises an exception' do
        expect { timezone_data }.to raise_error ArgumentError, 'Invalid format :unknown. Valid formats are :short, :full.'
      end
    end
  end

  describe '#local_time' do
    context 'when a valid timezone is passed' do
      it 'displays local time' do
        timezone = 'America/Los_Angeles'
        travel_to Time.find_zone(timezone).local(2021, 7, 20, 15, 30, 45)

        expect(helper.local_time(timezone)).to eq('15:30 (UTC -07:00)')
      end
    end

    context 'when an invalid timezone is passed' do
      it 'returns `nil`' do
        expect(helper.local_time('Foo/Bar')).to be_nil
      end
    end
  end
end
