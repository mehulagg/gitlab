# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::TemplateMetadata do
  let(:entry) { described_class.new(config) }

  describe 'validations' do
    context 'when entry config value is correct' do
      let(:config) do
        {
          name: 'Testing',
          usage: 'copy-paste'
        }
      end

      describe '#value' do
        it 'returns array of stages' do
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
      let(:config) do
        {
          name: 'Testing',
          usage: 'copy-paste',
          inclusion_type: 'shared-workflow'
        }
      end

      describe '#errors' do
        it 'saves errors' do
          expect(entry.errors)
            .to include 'template metadata inclusion type must be blank'
        end
      end

      describe '#valid?' do
        it 'is not valid' do
          expect(entry).not_to be_valid
        end
      end
    end
  end
end
