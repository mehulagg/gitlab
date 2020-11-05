# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::WebIde::Config::Entry::Schemas do
  let(:entry) { described_class.new(config) }

  describe 'validations' do
    before do
      entry.compose!
    end

    context 'when entry config value is correct' do
      let(:config) { [{ uri: 'http://test.uri', match: '*-config.yml' }] }

      it 'is valid' do
        expect(entry).to be_valid
      end
    end

    context 'when entry config value is incorrect' do
      let(:config) { { incorrect: 'schemas config' } }

      it 'is not valid' do
        expect(entry).not_to be_valid

        expect(entry.errors.first)
          .to match /schema/
      end

      describe '#errors' do
        it 'reports error about a config type' do
          expect(entry.errors)
            .to include 'schemas config should be a array'
        end
      end
    end
  end

  context 'when composed' do
    before do
      entry.compose!
    end

    describe '#value' do
      context 'when entry is correct' do
        let(:config) do
          [
            {
              uri: 'http://test.uri',
              match: '*-config.yml'
            }
          ]
        end

        it 'returns correct value' do
          expect(entry.value)
            .to eq([{
              uri: 'http://test.uri',
              match: '*-config.yml'
            }])
        end
      end
    end
  end
end
