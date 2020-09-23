# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Metrics::Generic do
  describe '#parse!' do
    subject { described_class.new.parse!(data, report) }

    let(:report) { Gitlab::Ci::Reports::Metrics::Report.new }

    context 'when data is sample metrics report' do
      let(:data) { File.read(Rails.root.join('ee/spec/fixtures/metrics.txt')) }

      it 'parses without error' do
        expect { subject }.not_to raise_error
      end

      it 'parses all metrics' do
        expect { subject }.to change { report.metrics.count }.from(0).to(2)
      end
    end

    context 'when string data has comments' do
      let(:data) { '# metric_name metric_value' }

      it 'parses without error' do
        expect { subject }.not_to raise_error
      end

      it 'does not parse comments' do
        expect { subject }.not_to change { report.metrics.count }.from(0)
      end
    end

    context 'when string data has metrics with labels' do
      let(:data) { 'metric_name{label_name="label value"}      metric_value' }

      it 'parses without error' do
        expect { subject }.not_to raise_error
      end

      it 'parses the metric with labels' do
        expect { subject }.to change { report.metrics.count }.from(0).to(1)
      end

      it 'stores the labels with the metric name' do
        subject

        expect(report.metrics['metric_name{label_name=label value}']).to eq('metric_value')
      end
    end

    context 'when string data has metrics with multiple values' do
      let(:data) { 'metric_name metric_value metric_second_value' }

      it 'parses without error' do
        expect { subject }.not_to raise_error
      end

      it 'parses the metric with multiple values' do
        expect { subject }.to change { report.metrics.count }.from(0).to(1)
      end

      it 'stores only the first metric value' do
        subject

        expect(report.metrics['metric_name']).to eq('metric_value')
      end
    end

    context 'when string data has an incomplete metric' do
      context 'when the incomplete metric does not have a value' do
        let(:data) { 'just_the_name' }

        it 'parses without error' do
          expect { subject }.not_to raise_error
        end

        it 'does not parse the metric' do
          expect { subject }.not_to change { report.metrics.count }.from(0)
        end
      end

      context 'when the incomplete metric is an empty line' do
        let(:data) { '' }

        it 'parses without error' do
          expect { subject }.not_to raise_error
        end

        it 'does not parse the metric' do
          expect { subject }.not_to change { report.metrics.count }.from(0)
        end
      end
    end
  end
end
