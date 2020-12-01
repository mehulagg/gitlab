# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::WebIde::Config::Entry::Schema::Uri do
  let(:uri) { described_class.new(config) }

  describe 'validations' do
    context 'when uri config value is correct' do
      let(:config) { 'https://someurl.com' }

      describe '#value' do
        it 'returns the url defined' do
          expect(uri.value).to eq config
        end
      end

      describe '#valid?' do
        it 'is valid' do
          expect(uri).to be_valid
        end
      end
    end

    context 'when value has a wrong type' do
      let(:config) { { test: true } }

      it 'reports errors about wrong type' do
        expect(uri.errors)
          .to include 'uri config should be a string'
      end
    end
  end

  describe '.default' do
    it 'returns empty string' do
      expect(described_class.default).to eq ''
    end
  end
end
