# frozen_string_literal: true

# This needs an `entity` object: Project or Group.
RSpec.shared_examples 'an entity with alpha/beta feature support' do
  where(level: %w[alpha beta])

  with_them do
    let(:method_name) { "#{level}_feature_available?" }

    context 'when license does not allow it' do
      before do
        stub_licensed_features(insights: false)
      end

      context 'when the feature flag is enabled globally' do
        before do
          stub_feature_flags(insights: true)
        end

        it { expect(entity.public_send(method_name, :insights)).to be_falsy }
      end

      context 'when the feature flag is disabled globally' do
        before do
          stub_feature_flags(insights: false)
        end

        it { expect(entity.public_send(method_name, :insights)).to be_falsy }

        context 'and enabled for the entity' do
          before do
            stub_feature_flags(insights: entity)
          end

          it { expect(entity.public_send(method_name, :insights)).to be_truthy }
        end
      end
    end

    context 'when license allows it' do
      before do
        stub_licensed_features(insights: true)
      end

      context 'when the feature flag is enabled globally' do
        before do
          stub_feature_flags(insights: true)
        end

        it { expect(entity.public_send(method_name, :insights)).to be_truthy }
      end

      context 'when the feature flag is disabled globally' do
        before do
          stub_feature_flags(insights: false)
        end

        it { expect(entity.public_send(method_name, :insights)).to be_falsy }

        context 'and enabled for the entity' do
          before do
            stub_feature_flags(insights: entity)
          end

          it { expect(entity.public_send(method_name, :insights)).to be_truthy }
        end
      end
    end
  end
end
