# frozen_string_literal: true

RSpec.shared_examples 'worker with data consistency delay' do |worker_class, data_consistency_delay: nil, feature_flag: nil|
  describe '.get_data_consistency_feature_flag_enabled?' do
    it 'returns true' do
      expect(worker_class.get_data_consistency_delay_feature_flag_enabled?).to be(true)
    end

    if feature_flag
      context "when feature flag :#{feature_flag} is disabled" do
        before do
          stub_feature_flags(feature_flag => false)
        end

        it 'returns false' do
          expect(worker_class.get_data_consistency_delay_feature_flag_enabled?).to be(false)
        end

        it 'does not call perform_in' do
          expect(worker_class).not_to receive(:perform_in)

          worker_class.perform_async
        end
      end
    end

    it 'delays scheduling a job by calling perform_in' do
      expect(worker_class).to receive(:perform_in).with(data_consistency_delay, 123)

      worker_class.perform_async(123)
    end
  end

  describe '.get_data_consistency_delay' do
    it 'returns correct data consistency' do
      expect(worker_class.get_data_consistency_delay).to eq(data_consistency_delay)
    end
  end
end
