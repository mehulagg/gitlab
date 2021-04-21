# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DevOpsReportHelper do
  subject { DevOpsReport::MetricPresenter.new(metric) }

  let(:metric) { build(:dev_ops_report_metric, created_at: DateTime.new(2021, 4, 3, 2, 1, 0) ) }

  describe '#devops_score_metrics' do
    let(:devops_score_metrics) { helper.devops_score_metrics(subject) }

    it { expect(devops_score_metrics[:averageScore]).to eq({ scoreLevel: { icon: "status-alert", label: "Moderate", variant: "warning" }, value: "55.9" } ) }

    it { expect(devops_score_metrics[:cards].first).to eq({ leadInstance: "9.3", score: "13.3", scoreLevel: { label: "Low", variant: "muted" }, title: "Issues created per active user", usage: "1.2" } ) }

    it { expect(devops_score_metrics[:createdAt]).to eq("2021-04-03 02:01") }
  end
end
