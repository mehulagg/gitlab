# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Feature::Definition do
  let(:attributes) do
    { name: 'feature_flag',
      type: 'development',
      default_enabled: true }
  end

  let(:path) { File.join('development', 'feature_flag.yml') }
  let(:definition) { described_class.new(path, attributes) }
  let(:yaml_content) { attributes.deep_stringify_keys.to_yaml }

  shared_examples 'tracking and raising exception for development' do |message:|
    before do
      expect(Gitlab::ErrorTracking)
        .to receive(:track_and_raise_for_dev_exception)
        .with(kind_of(Feature::InvalidFeatureFlagError))
        .and_call_original
    end

    context 'when on dev or test environment' do
      it 'raises an error' do
        expect { subject }.to raise_error(Feature::InvalidFeatureFlagError, message)
      end
    end

    context 'when on production environment' do
      before do
        allow(Gitlab::ErrorTracking).to receive(:should_raise_for_dev?).and_return(false)
      end

      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '#key' do
    subject { definition.key }

    it 'returns a symbol from name' do
      is_expected.to eq(:feature_flag)
    end
  end

  describe '#validate!' do
    using RSpec::Parameterized::TableSyntax

    where(:param, :value, :result) do
      :name            | nil                        | /Feature flag is missing name/
      :path            | nil                        | /Feature flag 'feature_flag' is missing path/
      :type            | nil                        | /Feature flag 'feature_flag' is missing type/
      :type            | 'invalid'                  | /Feature flag 'feature_flag' type 'invalid' is invalid/
      :path            | 'development/invalid.yml'  | /Feature flag 'feature_flag' has an invalid path/
      :path            | 'invalid/feature_flag.yml' | /Feature flag 'feature_flag' has an invalid type/
      :default_enabled | nil                        | /Feature flag 'feature_flag' is missing default_enabled/
    end

    with_them do
      let(:params) { attributes.merge(path: path) }

      subject(:validate!) { described_class.new(params[:path], params.except(:path)).validate! }

      before do
        params[param] = value

        expect(Gitlab::ErrorTracking)
          .to receive(:track_and_raise_for_dev_exception)
          .with(kind_of(Feature::InvalidFeatureFlagError))
          .and_call_original
      end

      it do
        expect { validate! }.to raise_error(result)
      end

      context 'when on production environment' do
        before do
          allow(Gitlab::ErrorTracking).to receive(:should_raise_for_dev?).and_return(false)
        end

        it 'does not raise an error' do
          expect { validate! }.not_to raise_error
        end
      end
    end
  end

  describe '#valid_usage!' do
    subject { definition.valid_usage!(type_in_code: type_in_code, default_enabled_in_code: default_enabled_in_code) }

    context 'validates type' do
      let(:type_in_code) { :invalid }
      let(:default_enabled_in_code) { false }

      it_behaves_like 'tracking and raising exception for development',
        message: /The `type:` of `feature_flag` is not equal to config/
    end

    context 'validates default enabled' do
      context 'with different value' do
        let(:type_in_code) { :development }
        let(:default_enabled_in_code) { false }

        it_behaves_like 'tracking and raising exception for development',
          message: /The `default_enabled:` of `feature_flag` is not equal to config/
      end

      it 'allows passing `default_enabled: :yaml`' do
        expect { definition.valid_usage!(type_in_code: :development, default_enabled_in_code: :yaml) }
          .not_to raise_error
      end
    end
  end

  describe '.paths' do
    it 'returns at least one path' do
      expect(described_class.paths).not_to be_empty
    end
  end

  describe '.load_from_file' do
    subject(:load_from_file) { described_class.send(:load_from_file, path) }

    it 'properly loads a definition from file' do
      expect_file_read(path, content: yaml_content)

      expect(load_from_file.attributes).to eq(definition.attributes)
    end

    context 'for missing file' do
      let(:path) { 'missing/feature-flag/file.yml' }

      it_behaves_like 'tracking and raising exception for development', message: /Invalid definition for/
    end

    context 'for invalid definition' do
      before do
        expect_file_read(path, content: '{}')
      end

      it_behaves_like 'tracking and raising exception for development', message: /Feature flag is missing name/
    end
  end

  describe '.load_all!' do
    let(:store1) { Dir.mktmpdir('path1') }
    let(:store2) { Dir.mktmpdir('path2') }
    let(:definitions) { {} }

    before do
      allow(described_class).to receive(:paths).and_return(
        [
          File.join(store1, '**', '*.yml'),
          File.join(store2, '**', '*.yml')
        ]
      )
    end

    subject { described_class.send(:load_all!) }

    it "when there's no feature flags a list of definitions is empty" do
      is_expected.to be_empty
    end

    it "when there's a single feature flag it properly loads them" do
      write_feature_flag(store1, path, yaml_content)

      is_expected.to be_one
    end

    context 'with the same feature flag is stored multiple times' do
      before do
        write_feature_flag(store1, path, yaml_content)
        write_feature_flag(store2, path, yaml_content)
      end

      it_behaves_like 'tracking and raising exception for development', message: /Feature flag 'feature_flag' is already defined/
    end

    context 'with one of the YAMLs is invalid' do
      before do
        write_feature_flag(store1, path, '{}')
      end

      it_behaves_like 'tracking and raising exception for development', message: /Feature flag is missing name/
    end

    after do
      FileUtils.rm_rf(store1)
      FileUtils.rm_rf(store2)
    end

    def write_feature_flag(store, path, content)
      path = File.join(store, path)
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir)
      File.write(path, content)
    end
  end

  describe '.valid_usage!' do
    before do
      allow(described_class).to receive(:definitions) do
        { definition.key => definition }
      end
    end

    context 'when a known feature flag is used' do
      it 'validates it usage' do
        expect(definition).to receive(:valid_usage!)

        described_class.valid_usage!(:feature_flag, type: :development, default_enabled: false)
      end
    end

    context 'when an unknown feature flag is used' do
      context 'for a type that is required to have all feature flags registered' do
        subject(:valid_usage!) { described_class.valid_usage!(:unknown_feature_flag, type: :development, default_enabled: false) }

        before do
          stub_const('Feature::Shared::TYPES', {
            development: { optional: false }
          })
        end

        it_behaves_like 'tracking and raising exception for development', message: /Missing feature definition for `unknown_feature_flag`/
      end

      context 'for a type that is optional' do
        before do
          stub_const('Feature::Shared::TYPES', {
            development: { optional: true }
          })
        end

        it 'does not raise exception' do
          expect do
            described_class.valid_usage!(:unknown_feature_flag, type: :development, default_enabled: false)
          end.not_to raise_error
        end
      end

      context 'for an unknown type' do
        subject(:valid_usage!) { described_class.valid_usage!(:unknown_feature_flag, type: :unknown_type, default_enabled: false) }

        it_behaves_like 'tracking and raising exception for development', message: /Unknown feature flag type used: `unknown_type`/
      end
    end
  end

  describe '.defaul_enabled?' do
    subject { described_class.default_enabled?(key) }

    context 'when feature flag exist' do
      let(:key) { definition.key }

      before do
        allow(described_class).to receive(:definitions) do
          { definition.key => definition }
        end
      end

      context 'when default_enabled is true' do
        it 'returns the value from the definition' do
          expect(subject).to eq(true)
        end
      end

      context 'when default_enabled is false' do
        let(:attributes) do
          { name: 'feature_flag',
            type: 'development',
            default_enabled: false }
        end

        it 'returns the value from the definition' do
          expect(subject).to eq(false)
        end
      end
    end

    context 'when feature flag does not exist' do
      let(:key) { :unknown_feature_flag }

      it_behaves_like 'tracking and raising exception for development',
        message: "The feature flag YAML definition for 'unknown_feature_flag' does not exist"

      context 'when on production environment' do
        before do
          allow(Gitlab::ErrorTracking).to receive(:should_raise_for_dev?).and_return(false)
        end

        it 'returns false' do
          expect(subject).to eq(false)
        end
      end
    end
  end
end
