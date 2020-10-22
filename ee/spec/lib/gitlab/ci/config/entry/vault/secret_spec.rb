# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Vault::Secret do
  let(:entry) { described_class.new(config) }

  describe 'validation' do
    before do
      entry.compose!
    end

    context 'when entry config value is correct' do
      let(:hash_config) do
        {
          engine: {
            name: 'kv-v2',
            path: 'some/path'
          },
          path: 'production/db',
          field: 'password'
        }
      end

      context 'when config is a hash' do
        let(:config) { hash_config }

        describe '#value' do
          it 'returns Vault secret configuration' do
            expect(entry.value).to eq(hash_config)
          end
        end

        describe '#valid?' do
          it 'is valid' do
            expect(entry).to be_valid
          end
        end
      end

      context 'when config is a string with engine path' do
        let(:config) { 'production/db/password@some/path' }

        describe '#value' do
          it 'returns Vault secret configuration' do
            expect(entry.value).to eq(hash_config)
          end
        end

        describe '#valid?' do
          it 'is valid' do
            expect(entry).to be_valid
          end
        end
      end

      context 'when config is a string without engine path' do
        let(:config) { 'production/db/password' }

        describe '#value' do
          it 'returns Vault secret configuration' do
            expect(entry.value).to eq(hash_config.deep_merge(engine: { path: 'kv-v2' }))
          end
        end

        describe '#valid?' do
          it 'is valid' do
            expect(entry).to be_valid
          end
        end
      end
    end
  end

  context 'when entry value is not correct' do
    describe '#errors' do
      context 'when there is an unknown key present' do
        let(:config) { { foo: :bar } }

        it 'reports error' do
          expect(entry.errors)
            .to include 'hash strategy config contains unknown keys: foo'
        end
      end

      context 'when path is not present' do
        let(:config) { {} }

        it 'reports error' do
          expect(entry.errors)
            .to include 'hash strategy path can\'t be blank'
        end
      end

      context 'when field is not present' do
        let(:config) { {} }

        it 'reports error' do
          expect(entry.errors)
            .to include 'hash strategy field can\'t be blank'
        end
      end

      context 'when engine is not a hash' do
        let(:config) { { engine: [] } }

        it 'reports error' do
          expect(entry.errors)
            .to include 'hash strategy engine should be a hash'
        end
      end
    end
  end
end
