# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkerAttributes do
  let(:worker) do
    Class.new do
      def self.name
        "TestWorker"
      end

      include ApplicationWorker
    end
  end

  describe '.data_consistency' do
    context 'with valid data_consistency' do
      it 'returns correct data_consistency' do
        worker.data_consistency(:sticky)

        expect(worker.get_data_consistency).to eq(:sticky)
      end
    end

    context 'when data_consistency is not provided' do
      it 'defaults to :always' do
        expect(worker.get_data_consistency).to eq(:always)
      end
    end

    context 'with invalid data_consistency' do
      it 'raise exception' do
        expect { worker.data_consistency(:invalid) }
          .to raise_error('Invalid data consistency: invalid')
      end
    end

    context 'when job is idempotent' do
      context 'when data_consistency is not :always' do
        it 'raise exception' do
          worker.idempotent!

          expect { worker.data_consistency(:sticky) }
            .to raise_error("Class can't be marked as idempotent if data_consistency is not set to :always")
        end
      end

      context 'when feature_flag is provided' do
        before do
          stub_feature_flags(test_feature_flag: false)
          skip_feature_flags_yaml_validation
          skip_default_enabled_yaml_check
        end

        it 'returns correct feature flag value' do
          worker.data_consistency(:sticky, feature_flag: :test_feature_flag)

          expect(worker.get_data_consistency_feature_flag_enabled?).not_to be_truthy
        end
      end
    end
  end

  describe '.idempotent!' do
    it 'sets `idempotent` attribute of the worker class to true' do
      worker.idempotent!

      expect(worker.send(:class_attributes)[:idempotent]).to eq(true)
    end

    context 'when a feature flag is passed' do
      before do
        skip_feature_flags_yaml_validation
        skip_default_enabled_yaml_check
      end

      it 'sets `idempotent_feature_flag` attribute of the worker class' do
        worker.idempotent!(feature_flag: :my_feature_flag)

        expect(worker.send(:class_attributes)[:idempotent_feature_flag]).to eq(:my_feature_flag)
      end
    end

    context 'when data consistency is not :always' do
      it 'raise exception' do
        worker.data_consistency(:sticky)

        expect { worker.idempotent! }
          .to raise_error("Class can't be marked as idempotent if data_consistency is not set to :always")
      end
    end
  end

  describe '.idempotent?' do
    subject(:idempotent?) { worker.idempotent? }

    context 'when the worker is idempotent' do
      before do
        worker.idempotent!
      end

      it { is_expected.to be_truthy }
    end

    context 'when the worker is idempotent with a feature flag' do
      before do
        skip_feature_flags_yaml_validation
        skip_default_enabled_yaml_check

        worker.idempotent!(feature_flag: :my_feature_flag)
      end

      it { is_expected.to be_truthy }

      context 'when the idempotent feature flag is disabled' do
        before do
          stub_feature_flags(my_feature_flag: false)
        end

        it { is_expected.to be_falsey }
      end
    end

    context 'when the worker is not idempotent' do
      it { is_expected.to be_falsey }
    end
  end
end
