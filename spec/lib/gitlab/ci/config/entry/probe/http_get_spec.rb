# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Probe::HttpGet do
  let(:entry) { described_class.new(config) }

  context 'when configuration is valid' do
    let(:config) { { port: 123, scheme: 'http', path: '/', headers: [ 'x-custom: value' ] } }

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

    context "when 'scheme' keyword is https" do
      let(:config) { { scheme: 'https' } }

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
        expect(entry.errors).to include 'http get config contains unknown keys: unknown'
      end
    end

    context "when 'port' keyword is not an integer" do
      let(:config) { { port: "foo" } }

      it 'reports error' do
        expect(entry.errors).to include 'http get port should be a integer'
      end
    end

    context "when 'scheme' keyword is not a string" do
      let(:config) { { scheme: 123 } }

      it 'reports error' do
        expect(entry.errors).to include 'http get scheme should be a string'
        expect(entry.errors).to include 'http get scheme should be http or https'
      end
    end

    context "when 'path' keyword is not a string" do
      let(:config) { { path: 123 } }

      it 'reports error' do
        expect(entry.errors).to include 'http get path should be a string'
      end
    end

    context "when 'headers' keyword is not an array" do
      let(:config) { { headers: "key: value" } }

      it 'reports error' do
        expect(entry.errors).to include 'http get headers should be an array of strings'
      end
    end

    context "when 'headers' keyword contains invalid header format" do
      let(:config) { { headers: [ "key=value" ] } }

      it 'reports error' do
        expect(entry.errors).to include "http get headers must be in the format of 'header-name: value'"
      end
    end
  end
end
