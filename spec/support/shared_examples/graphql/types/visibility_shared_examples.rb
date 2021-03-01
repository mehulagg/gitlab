# frozen_string_literal: true

RSpec.shared_examples 'a GraphQL field or argument that checks feature flag visibility' do
  describe '#visible?' do
    context 'and has a feature_flag' do
      let(:flag) { :test_feature }
      let(:context) { {} }

      before do
        skip_feature_flags_yaml_validation
      end

      it 'returns false if the feature is not enabled' do
        stub_feature_flags(flag => false)

        expect(subject.visible?(context)).to eq(false)
      end

      it 'returns true if the feature is enabled' do
        expect(subject.visible?(context)).to eq(true)
      end
    end
  end

  describe '#description' do
    context 'feature flag given' do
      let(:flag) { :test_flag }

      it 'prepends the description' do
        expect(subject.description). to eq 'Test description. Available only when feature flag `test_flag` is enabled.'
      end

      context 'falsey feature_flag values' do
        using RSpec::Parameterized::TableSyntax

        where(:flag, :feature_value) do
          ''  | false
          ''  | true
          nil | false
          nil | true
        end

        with_them do
          it 'returns the correct description' do
            expect(subject.description).to eq('Test description.')
          end
        end
      end
    end
  end
end
