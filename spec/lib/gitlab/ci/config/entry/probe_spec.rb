# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Probe do
  let(:entry) { described_class.new(config) }

  context 'when configuration is valid' do
    let(:config) { { exec: { command: ["cmd", "-c"] }, retries: 1, initial_delay: 1, period: 1, timeout: 1 } }

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
    let(:config) { { retries: 1, initial_delay: 1, period: 1, timeout: 1 } }

    describe '#valid?' do
      it 'is invalid' do
        expect(entry).not_to be_valid
        expect(entry.errors).to include 'probe config requires tcp, http_get or exec probe'
      end
    end

    context "when 'retries' keyword is not an integer" do
      let(:config) { { retries: "foo" } }

      it 'reports error' do
        expect(entry.errors).to include 'probe retries should be a integer'
      end
    end

    context "when 'initial_delay' keyword is not an integer" do
      let(:config) { { initial_delay: "foo" } }

      it 'reports error' do
        expect(entry.errors).to include 'probe initial delay should be a integer'
      end
    end

    context "when 'period' keyword is not an integer" do
      let(:config) { { period: "foo" } }

      it 'reports error' do
        expect(entry.errors).to include 'probe period should be a integer'
      end
    end

    context "when 'timeout' keyword is not an integer" do
      let(:config) { { timeout: "foo" } }

      it 'reports error' do
        expect(entry.errors).to include 'probe timeout should be a integer'
      end
    end
  end
end
