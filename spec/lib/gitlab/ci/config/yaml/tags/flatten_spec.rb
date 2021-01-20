# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::YAML::Tags::Flatten do
  let(:config) { Gitlab::Config::Loader::Yaml.new(yaml).load! }

  describe '.deep_resolve' do
    subject { described_class.deep_resolve(config) }

    before do
      Gitlab::Ci::Config::YAML::Tags.load_custom_tags_into_psych
    end

    context 'with array objects' do
      let(:yaml) do
        <<~YML
        test:
          script: !flatten
            - ['echo creating environment 1', 'echo creating environment 2']
            - echo running my own command
            - ['echo deleting environment 1', 'echo deleting environment 2']
        YML
      end

      it 'flattens nested arrays' do
        expect(subject[:test][:script]).to eq(
          [
            'echo creating environment 1',
            'echo creating environment 2',
            'echo running my own command',
            'echo deleting environment 1',
            'echo deleting environment 2'
          ]
        )
      end
    end

    context 'with already flat arrays' do
      let(:yaml) do
        <<~YML
        test:
          script: !flatten
            - 'echo creating environment 1'
            - 'echo creating environment 2'
            - echo running my own command
            - 'echo deleting environment 1'
            - 'echo deleting environment 2'
        YML
      end

      it 'returns the array as it is' do
        expect(subject[:test][:script]).to eq(
          [
            'echo creating environment 1',
            'echo creating environment 2',
            'echo running my own command',
            'echo deleting environment 1',
            'echo deleting environment 2'
          ]
        )
      end
    end

    context 'without data' do
      let(:yaml) { 'script: !flatten' }

      it 'returns an empty array' do
        is_expected.to match({ script: [] })
      end
    end

    context 'with wrong data' do
      let(:yaml) { 'script: !flatten 1' }

      it 'raises an error' do
        expect { subject }.to raise_error Gitlab::Ci::Config::YAML::Tags::NotValidError, '!flatten "1" is not valid'
      end
    end
  end
end
