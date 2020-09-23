# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Secrets do
  let(:entry) { described_class.new(config) }

  describe 'validation' do
    before do
      entry.compose!
    end

    context 'when entry config value is correct' do
      let(:config) { {} }

      describe '#value' do
        it 'returns secrets configuration' do
          expect(entry.value).to eq config
        end
      end

      describe '#valid?' do
        it 'is valid' do
          expect(entry).to be_valid
        end
      end
    end

    context 'when config is of incorrect type' do
      let(:config) { [] }

      it 'reports error' do
        expect(entry.errors)
          .to include 'secrets config should be a hash'
      end
    end
  end

  describe '#compose!' do
    context 'when valid secret entries composed' do
      let(:config) do
        {
          DATABASE_PASSWORD: {
            vault: {
              engine: { name: 'kv-v2', path: 'kv-v2' },
              path: 'production/db',
              field: 'password'
            }
          }
        }
      end

      before do
        entry.compose!
      end

      describe '#value' do
        it 'returns key value' do
          expect(entry.value).to eq(config)
        end
      end

      describe '#descendants' do
        it 'creates valid descendant nodes' do
          expect(entry.descendants).to all(be_a(Gitlab::Ci::Config::Entry::Secret))
        end
      end
    end
  end
end
