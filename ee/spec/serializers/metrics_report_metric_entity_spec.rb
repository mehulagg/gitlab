# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MetricsReportMetricEntity do
  let(:metric) { ::Gitlab::Ci::Reports::Metrics::ReportsComparer::ComparedMetric.new('metric_name', 'metric_value') }
  let(:entity) { described_class.new(metric) }

  describe '#as_json' do
    subject { entity.as_json }

    it 'contains the correct metric' do
      expect(subject[:name]).to eq('metric_name')
      expect(subject[:value]).to eq('metric_value')
    end

    context 'when the metric did not change' do
      before do
        metric.previous_value = metric.value
      end

      it 'does not expose previous_value' do
        expect(subject).not_to include(:previous_value)
      end
    end

    context 'when the metric changed' do
      before do
        metric.previous_value = 'previous_metric_value'
      end

      it 'exposes the previous_value' do
        expect(subject).to include(:previous_value)
        expect(subject[:previous_value]).to eq('previous_metric_value')
      end
    end
  end
end
