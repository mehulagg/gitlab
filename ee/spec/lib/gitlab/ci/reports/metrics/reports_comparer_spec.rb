# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Metrics::ReportsComparer do
  let(:first_report) { build :ci_reports_metrics_report, :base_metrics }
  let(:second_report) { build :ci_reports_metrics_report, :head_metrics }
  let(:report_comparer) { described_class.new(first_report, second_report) }

  describe '#new_metrics' do
    subject { report_comparer.new_metrics }

    it 'reports new metrics' do
      expect(subject.count).to eq 1
      expect(subject.first.name).to eq 'extra_metric_name'
    end
  end

  describe '#existing_metrics' do
    subject { report_comparer.existing_metrics }

    it 'reports existing metrics' do
      expect(subject.count).to eq 1
      expect(subject.first.name).to eq 'metric_name'
    end

    context 'when existing metric changes' do
      before do
        second_report.add_metric('metric_name', 'new_metric_value')
      end

      it 'sets previous value' do
        expect(subject.first.previous_value).to eq 'metric_value'
        expect(subject.first.value).to eq 'new_metric_value'
      end
    end
  end

  describe '#removed_metrics' do
    subject { report_comparer.removed_metrics }

    it 'reports removed metrics' do
      expect(subject.count).to eq 1
      expect(subject.first.name).to eq 'second_metric_name'
    end
  end
end
