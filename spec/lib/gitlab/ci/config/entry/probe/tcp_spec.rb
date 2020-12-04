# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Probe::Tcp do
  let(:entry) { described_class.new(config) }

  context 'when configuration is valid' do
    let(:config) { { port: 123 } }

    describe '#valid?' do
      it 'is valid' do
        expect(entry).to be_valid
      end
    end

    describe '#value' do
      it 'returns valid config' do
        expect(entry.value).to eq(config)
      end
    end
  end

  context 'when configuration is invalid' do
    let(:config) { { unknown: 1 } }

    describe '#valid?' do
      it 'is invalid' do
        expect(entry).not_to be_valid
        expect(entry.errors).to include 'tcp config contains unknown keys: unknown'
        expect(entry.errors).to include 'tcp port should be a integer'
        expect(entry.errors).to include "tcp port can't be blank"
      end
    end
  end
end
