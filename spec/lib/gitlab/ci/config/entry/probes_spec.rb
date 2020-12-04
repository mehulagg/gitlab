# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Probes do
  let(:entry) { described_class.new(config) }

  before do
    entry.compose!
  end

  context 'when configuration is valid' do
    let(:config) { [
        { exec: { command: ["cmd", "-c"] }, retries: 1, initial_delay: 1, period: 1, timeout: 1 },
        { http_get: { path: '/healthz' }, timeout: 10 },
        { tcp: { port: 123 }, retries: 5, timeout: 5 },
    ] }

    describe '#valid?' do
      it 'is valid' do
        expect(entry).to be_valid
      end
    end

    describe '#value' do
      it 'returns valid array' do
        expect(entry.value).to eq(config)
      end
    end
  end

  context 'when configuration is invalid' do
    let(:config) { { exec: { command: ["cmd", "-c"] } } }

    describe '#valid?' do
      it 'is invalid' do
        expect(entry).not_to be_valid
      end
    end
  end
end
