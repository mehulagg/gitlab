# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Vault::Engine do
  let(:entry) { described_class.new(config) }

  describe 'validation' do
    before do
      entry.compose!
    end

    context 'when entry config value is correct' do
      let(:config) { { name: 'kv-v2', path: 'kv-v2' } }

      describe '#value' do
        it 'returns Vault secret engine configuration' do
          expect(entry.value).to eq config
        end
      end

      describe '#valid?' do
        it 'is valid' do
          expect(entry).to be_valid
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
            .to include 'engine config contains unknown keys: foo'
        end
      end

      context 'when name and path are missing' do
        let(:config) { {} }

        it 'reports error' do
          expect(entry.errors).to include 'engine config missing required keys: name, path'
        end
      end

      context 'when name and path are blank' do
        let(:config) { { name: '', path: '' } }

        it 'reports error' do
          aggregate_failures do
            expect(entry.errors).to include 'engine name can\'t be blank'
            expect(entry.errors).to include 'engine path can\'t be blank'
          end
        end
      end
    end
  end
end
