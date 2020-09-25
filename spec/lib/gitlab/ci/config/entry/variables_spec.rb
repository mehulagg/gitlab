# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Variables do
  let(:entry) { described_class.new(config) }

  describe 'validations' do
    shared_examples 'valid config' do
      describe '#value' do
        it 'returns hash with key value strings' do
          expect(entry.value).to eq result
        end
      end

      describe '#errors' do
        it 'does not append errors' do
          expect(entry.errors).to be_empty
        end
      end

      describe '#valid?' do
        it 'is valid' do
          expect(entry).to be_valid
        end
      end
    end

    context 'when entry config value has key-value pairs' do
      let(:config) do
        { 'VARIABLE_1' => 'value 1', 'VARIABLE_2' => 'value 2' }
      end
      let(:result) do
        { 'VARIABLE_1' => { 'value' => 'value 1', 'description' => '' },
          'VARIABLE_2' => { 'value' => 'value 2', 'description' => '' } }
      end

      it_behaves_like 'valid config'

      context 'when FF ci_prefilled_variables is disabled' do
        before do
          stub_feature_flags(ci_prefilled_variables: false)
        end

        let(:result) do
          { 'VARIABLE_1' => 'value 1',
            'VARIABLE_2' => 'value 2' }
        end

        it_behaves_like 'valid config'
      end
    end

    context 'with numeric keys and values in the config' do
      let(:config) { { 10 => 20 } }
      let(:result) do
        { '10' => { 'value' => '20', 'description' => '' } }
      end

      it_behaves_like 'valid config'
    end

    context 'when entry config value has key-value pair and key-value-description' do
      let(:config) do
        { 'VARIABLE_1' => { value: 'value 1', description: 'variable 1' },
          'VARIABLE_2' => 'value 2' }
      end
      let(:result) do
        { 'VARIABLE_1' => { 'value' => 'value 1', 'description' => 'variable 1' },
          'VARIABLE_2' => { 'value' => 'value 2', 'description' => '' } }
      end

      it_behaves_like 'valid config'

      context 'when FF ci_prefilled_variables is disabled' do
        before do
          stub_feature_flags(ci_prefilled_variables: false)
        end

        it 'is not valid' do
          expect(entry).not_to be_valid
        end
      end
    end

    context 'when entry value is not correct' do
      let(:config) { [:VAR, 'test'] }

      describe '#errors' do
        it 'saves errors' do
          expect(entry.errors)
            .to include /should be a hash of key value pairs/
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
