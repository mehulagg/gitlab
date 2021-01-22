# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::Ci::Variables::Helpers do
  describe '.merge_variables' do
    let(:current_variables) do
      [{ key: 'key1', value: 'value1' },
       { key: 'key2', value: 'value2' }]
    end

    let(:new_variables) do
      [{ key: 'key2', value: 'value22' },
       { key: 'key3', value: 'value3' }]
    end

    let(:expected_result) do
      [{ key: 'key1', value: 'value1', public: true },
       { key: 'key2', value: 'value22', public: true },
       { key: 'key3', value: 'value3', public: true }]
    end

    subject(:result) { described_class.merge_variables(current_variables, new_variables) }

    it do
      is_expected.to eq(expected_result)
    end

    context 'when new variables is a hash' do
      let(:new_variables) do
        { 'key2' => 'value22', 'key3' => 'value3' }
      end

      it do
        is_expected.to eq(expected_result)
      end
    end

    context 'when new variables is a hash with symbol keys' do
      let(:new_variables) do
        { key2: 'value22', key3: 'value3' }
      end

      it do
        is_expected.to eq(expected_result)
      end
    end

    context 'when new variables is nil' do
      let(:new_variables) {}

      it do
        is_expected.to eq([{ key: 'key1', value: 'value1', public: true },
                           { key: 'key2', value: 'value2', public: true }])
      end
    end
  end

  describe '.transform_to_yaml_variables' do
    let(:variables) do
      { 'key1' => 'value1', 'key2' => 'value2' }
    end

    subject(:result) { described_class.transform_to_yaml_variables(variables) }

    it do
      is_expected.to eq([{ key: 'key1', value: 'value1', public: true },
                         { key: 'key2', value: 'value2', public: true }])
    end

    context 'when variables is nil' do
      let(:variables) {}

      it { is_expected.to eq([]) }
    end
  end

  describe '.transform_from_yaml_variables' do
    let(:variables) do
      [{ key: 'key1', value: 'value1', public: true },
       { key: 'key2', value: 'value2', public: true }]
    end

    subject(:result) { described_class.transform_from_yaml_variables(variables) }

    it do
      is_expected.to eq({ 'key1' => 'value1', 'key2' => 'value2' })
    end

    context 'when variables is nil' do
      let(:variables) {}

      it { is_expected.to eq({}) }
    end

    context 'when variables is a hash' do
      let(:variables) do
        { key1: 'value1', 'key2' => 'value2' }
      end

      it do
        is_expected.to eq({ 'key1' => 'value1', 'key2' => 'value2' })
      end
    end
  end
end
