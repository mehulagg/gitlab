# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::StaticSiteEditor::Config::FileConfig::Entry::Mounts do
  let(:entry) { described_class.new(config) }

  describe 'validation' do
    context 'when entry config value is correct' do
      let(:config) do
        [
          {
            source: 'source',
            target: ''
          },
          {
            source: 'sub-site/source',
            target: 'sub-site'
          }
        ]
      end

      describe '#value' do
        it 'returns mounts configuration' do
          expect(entry.value).to eq config
        end
      end

      describe '#valid?' do
        it 'is valid' do
          expect(entry).to be_valid
        end
      end
    end

    context 'when entry value is not correct' do
      describe '#errors' do
        context 'when type is invalid' do
          let(:config) { { not_an_array: true } }

          it 'reports error' do
            expect(entry.errors)
              .to include 'mounts config should be a array'
          end
        end
      end
    end
  end

  describe '.default' do
    it 'returns default mounts' do
      expect(described_class.default)
        .to eq([{
                 source: 'source',
                 target: ''
               }])
    end
  end
end
