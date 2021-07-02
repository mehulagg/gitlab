# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ElasticIndexInitialBulkCronWorker do
  describe '.perform_async' do
    it 'delays scheduling a job by calling perform_in with default delay' do
      expect(described_class).to receive(:perform_in).with(ApplicationWorker::DEFAULT_DELAY_INTERVAL.second, 123)

      described_class.perform_async(123)
    end
  end

  it_behaves_like 'worker with data consistency',
                  described_class,
                  data_consistency: :sticky
end
