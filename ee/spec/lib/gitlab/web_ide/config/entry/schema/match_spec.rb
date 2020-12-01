# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::WebIde::Config::Entry::Schema::Match do
  let(:match) { described_class.new(config) }

  describe 'validations' do
    context 'when match config value is correct' do
      let(:config) { ['*.json'] }

      describe '#value' do
        it 'returns the match glob pattern defined' do
          expect(match.value).to eq config
        end
      end

      describe '#valid?' do
        it 'is valid' do
          expect(match).to be_valid
        end
      end
    end

    context 'when value has a wrong type' do
      let(:config) { { test: true } }

      it 'reports errors about wrong type' do
        expect(match.errors)
          .to include 'match config should be an array of strings'
      end
    end
  end

  describe '.default' do
    it 'returns empty array' do
      expect(described_class.default).to eq []
    end
  end
end
