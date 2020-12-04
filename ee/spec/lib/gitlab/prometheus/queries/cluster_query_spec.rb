# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Prometheus::Queries::ClusterQuery do
  let(:client) { double('prometheus_client', query_range: nil) }

  subject { described_class.new(client) }

  around do |example|
    freeze_time { example.run }
  end

  it 'load cluster metrics from yaml' do
    expect(Gitlab::Prometheus::AdditionalMetricsParser).to receive(:load_groups_from_yaml).with('queries_cluster_metrics.yml').and_call_original

    subject.query
  end

  it 'sends queries to prometheus' do
    subject.query

    expect(client).to have_received(:query_range).with(anything, start_time: 8.hours.ago, end_time: Time.now).at_least(1)
  end
end
