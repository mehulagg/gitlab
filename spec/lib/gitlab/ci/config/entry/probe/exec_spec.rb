# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Probe::Exec do
  let(:entry) { described_class.new(config) }

  context 'when configuration is valid' do
    let(:config) { ["cmd", "-c"] }

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
    let(:config) { [123] }

    describe '#valid?' do
      it 'is invalid' do
        expect(entry).not_to be_valid
        expect(entry.errors).to include 'exec config should be an array of strings'
      end
    end
  end
end
