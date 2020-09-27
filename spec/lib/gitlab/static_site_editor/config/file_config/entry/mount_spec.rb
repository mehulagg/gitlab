# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::StaticSiteEditor::Config::FileConfig::Entry::Mount do
  let(:entry) { described_class.new(config) }

  describe 'validation' do
    context 'when entry config value is correct' do
      context 'and target is a non-empty string' do
        let(:config) do
          {
            source: 'source',
            target: 'sub-site'
          }
        end

        describe '#value' do
          it 'returns mount configuration' do
            expect(entry.value).to eq config
          end
        end

        describe '#valid?' do
          it 'is valid' do
            expect(entry).to be_valid
          end
        end
      end
      context 'and target is an empty string' do
        let(:config) do
          {
            source: 'source',
            target: ''
          }
        end

        describe '#value' do
          it 'returns mount configuration' do
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
        context 'when source is not a string' do
          let(:config) { { source: 123, target: 'target' } }

          it 'reports error' do
            expect(entry.errors)
              .to include 'mount source should be a string'
          end
        end

        context 'when source is not present' do
          let(:config) { { target: 'target' } }

          it 'reports error' do
            expect(entry.errors)
              .to include "mount source can't be blank"
          end
        end

        context 'when target is not a string' do
          let(:config) { { source: 'source', target: 123 } }

          it 'reports error' do
            expect(entry.errors)
              .to include 'mount target should be a string'
          end
        end

        context 'when there is an unknown key present' do
          let(:config) { { test: 100 } }

          it 'reports error' do
            expect(entry.errors)
              .to include 'mount config contains unknown keys: test'
          end
        end
      end
    end
  end

  describe '.default' do
    it 'returns default mount' do
      expect(described_class.default)
        .to eq({
                 source: 'source',
                 target: ''
               })
    end
  end
end
