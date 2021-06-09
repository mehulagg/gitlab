# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::UsageDataInstrumentation do
  let(:usage_data) { { uuid: '1234', boards: 100 } }
  let(:usage_data_instrumentation) { { issues: 1234, boards: 100 } }

  describe '.data' do
    context 'with usage_data_instrumentation feature enabled' do
      it 'merges the data from instrumentation classes' do
        stub_feature_flags(usage_data_instrumentation: true)

        expect(Gitlab::UsageDataMetrics).to receive(:uncached_data).and_return(usage_data_instrumentation)
        expect(Gitlab::UsageData).to receive(:data).with(force_refresh: true).and_return(usage_data)

        expect(described_class.data(force_refresh: true)).to eq({ uuid: '1234', boards: 100, issues: 1234 })
      end
    end

    context 'with usage_data_instrumentation feature disabled' do
      it 'does not merge the data from instrumentation classes' do
        stub_feature_flags(usage_data_instrumentation: false)

        expect(Gitlab::UsageDataMetrics).not_to receive(:uncached_data)
        expect(Gitlab::UsageData).to receive(:data).with(force_refresh: true).and_return(usage_data)

        expect(described_class.data(force_refresh: true)).to eq({ uuid: '1234', boards: 100 })
      end
    end
  end
end
