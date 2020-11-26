# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Variables::Collection do
  before do
    stub_feature_flags(variable_inside_variable: false)
  end

  describe '.new' do
    it 'can be initialized with an array' do
      variable = { key: 'VAR', value: 'value', public: true, masked: false }

      collection = described_class.new([variable])

      expect(collection.first.to_runner_variable).to eq variable
    end

    it 'can be initialized without an argument' do
      expect(subject).to be_none
    end
  end

  describe '#append' do
    it 'appends a hash' do
      subject.append(key: 'VARIABLE', value: 'something')

      expect(subject).to be_one
    end

    it 'appends a Ci::Variable' do
      subject.append(build(:ci_variable))

      expect(subject).to be_one
    end

    it 'appends an internal resource' do
      collection = described_class.new([{ key: 'TEST', value: '1' }])

      subject.append(collection.first)

      expect(subject).to be_one
    end

    it 'returns self' do
      expect(subject.append(key: 'VAR', value: 'test'))
        .to eq subject
    end
  end

  describe '#concat' do
    it 'appends all elements from an array' do
      collection = described_class.new([{ key: 'VAR_1', value: '1' }])
      variables = [{ key: 'VAR_2', value: '2' }, { key: 'VAR_3', value: '3' }]

      collection.concat(variables)

      expect(collection).to include(key: 'VAR_1', value: '1', public: true)
      expect(collection).to include(key: 'VAR_2', value: '2', public: true)
      expect(collection).to include(key: 'VAR_3', value: '3', public: true)
    end

    it 'appends all elements from other collection' do
      collection = described_class.new([{ key: 'VAR_1', value: '1' }])
      additional = described_class.new([{ key: 'VAR_2', value: '2' },
                                        { key: 'VAR_3', value: '3' }])

      collection.concat(additional)

      expect(collection).to include(key: 'VAR_1', value: '1', public: true)
      expect(collection).to include(key: 'VAR_2', value: '2', public: true)
      expect(collection).to include(key: 'VAR_3', value: '3', public: true)
    end

    it 'does not concatenate resource if it undefined' do
      collection = described_class.new([{ key: 'VAR_1', value: '1' }])

      collection.concat(nil)

      expect(collection).to be_one
    end

    it 'returns self' do
      expect(subject.concat([key: 'VAR', value: 'test']))
        .to eq subject
    end
  end

  describe '#+' do
    it 'makes it possible to combine with an array' do
      collection = described_class.new([{ key: 'TEST', value: '1' }])
      variables = [{ key: 'TEST', value: 'something' }]

      expect((collection + variables).count).to eq 2
    end

    it 'makes it possible to combine with another collection' do
      collection = described_class.new([{ key: 'TEST', value: '1' }])
      other = described_class.new([{ key: 'TEST', value: '2' }])

      expect((collection + other).count).to eq 2
    end
  end

  describe '#to_runner_variables' do
    it 'creates an array of hashes in a runner-compatible format' do
      collection = described_class.new([{ key: 'TEST', value: '1' }])

      expect(collection.to_runner_variables)
        .to eq [{ key: 'TEST', value: '1', public: true, masked: false }]
    end

    context 'when variable_inside_variable feature flag is disabled' do
      before do
        stub_feature_flags(variable_inside_variable: false)
      end

      context 'with cyclic dependency among variable values' do
        let(:collection) do
          described_class.new([
            { key: 'VAR_1', value: 'ref-$VAR_2' },
            { key: 'VAR_2', value: 'ref-$VAR_3' },
            { key: 'VAR_3', value: 'ref-$VAR_1' }
          ])
        end

        it 'does not resolve references to variables by default' do
          expect(collection.to_runner_variables)
            .to eq [
              { key: 'VAR_1', value: 'ref-$VAR_2', public: true, masked: false },
              { key: 'VAR_2', value: 'ref-$VAR_3', public: true, masked: false },
              { key: 'VAR_3', value: 'ref-$VAR_1', public: true, masked: false }
            ]
        end

        it 'does not raise' do
          expect { collection.to_runner_variables }.not_to raise_error
        end
      end
    end

    context 'when variable_inside_variable feature flag is enabled' do
      before do
        stub_feature_flags(variable_inside_variable: true)
      end

      context 'with cyclic dependency among variable values' do
        let(:collection) do
          described_class.new([
            { key: 'VAR_1', value: 'ref-$VAR_2' },
            { key: 'VAR_2', value: 'ref-$VAR_3' },
            { key: 'VAR_3', value: 'ref-$VAR_1' }
          ])
        end

        it 'raises Gitlab::Ci::Variables::CyclicVariableReference' do
          expect { collection.to_runner_variables }
            .to raise_error(Gitlab::Ci::Variables::CyclicVariableReference)
        end
      end

      it 'resolves references to variables and topologically sorts result' do
        collection = described_class.new([
          { key: 'IMAGE_TAG', value: 'docker-image-$CI_PIPELINE_ID' },
          { key: 'CI_PIPELINE_ID', value: '102' }
        ])

        expect(collection.to_runner_variables)
          .to eq [
            { key: 'CI_PIPELINE_ID', value: '102', public: true, masked: false },
            { key: 'IMAGE_TAG', value: 'docker-image-102', public: true, masked: false }
          ]
      end

      it 'does not resolve references to unknown variables' do
        collection = described_class.new([{ key: 'IMAGE_TAG', value: 'docker-image-$CI_PIPELINE_ID' }])

        expect(collection.to_runner_variables)
          .to eq [{ key: 'IMAGE_TAG', value: 'docker-image-$CI_PIPELINE_ID', public: true, masked: false }]
      end
    end
  end

  describe '#to_hash' do
    context 'when variable_inside_variable feature flag is disabled' do
      before do
        stub_feature_flags(variable_inside_variable: false)
      end

      it 'returns regular hash in valid order without duplicates' do
        collection = described_class.new
          .append(key: 'TEST1', value: 'test-1')
          .append(key: 'TEST2', value: 'test-2')
          .append(key: 'TEST1', value: 'test-3')

        expect(collection.to_hash).to eq('TEST1' => 'test-3',
                                        'TEST2' => 'test-2')

        expect(collection.to_hash).to include(TEST1: 'test-3')
        expect(collection.to_hash).not_to include(TEST1: 'test-1')
      end
    end

    context 'when variable_inside_variable feature flag is enabled' do
      before do
        stub_feature_flags(variable_inside_variable: true)
      end

      it 'returns regular hash in topological order without duplicates' do
        collection = described_class.new
          .append(key: 'TEST1', value: '${TEST2}-1')
          .append(key: 'TEST2', value: 'test-2')
          .append(key: 'TEST2', value: 'test-3')

        expect(collection.to_hash).to eq('TEST2' => 'test-3',
                                         'TEST1' => 'test-3-1')

        expect(collection.to_hash).to include(TEST1: 'test-3-1')
        expect(collection.to_hash).not_to include(TEST2: 'test-2')
      end
    end
  end
end
