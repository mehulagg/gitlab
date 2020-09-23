# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::Reindexing::ReindexAction, '.keep_track_of' do
  let(:index) { double('index', identifier: 'public.something', ondisk_size_bytes: 10240, reset: nil) }
  let(:size_after) { 512 }

  it 'yields to the caller' do
    expect { |b| described_class.keep_track_of(index, &b) }.to yield_control
  end

  def find_record
    described_class.find_by(index_identifier: index.identifier)
  end

  it 'creates the record with a start time and updates its end time' do
    Timecop.freeze do
      described_class.keep_track_of(index) do
        expect(find_record.reindex_start).to be_within(1.second).of(Time.zone.now)

        Timecop.travel(Time.zone.now + 10.seconds)
      end

      expect(find_record.reindex_end).to be_within(1.second).of(Time.zone.now)
    end
  end

  it 'creates the record with the indexes start size and updates its end size' do
    Timecop.freeze do
      described_class.keep_track_of(index) do
        expect(find_record.ondisk_size_bytes_start).to eq(index.ondisk_size_bytes)

        expect(index).to receive(:reset).once
        allow(index).to receive(:ondisk_size_bytes).and_return(size_after)
      end

      expect(find_record.ondisk_size_bytes_end).to eq(size_after)
    end
  end
end
