# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Prometheus::Queries::PacketFlowMetricsQuery do
  let(:namespace) { 'query-12345678-production' }
  let(:query_response) do
    [
      { "metric" => { "verdict" => "FORWARDED" }, "value" => [1582231596.64, "73772.43143284984"] },
      { "metric" => { "verdict" => "DROPPED" }, "value" => [1582231596.64, "5.002730665588791"] }
    ]
  end

  let(:client) { double('prometheus_client', query: query_response) }

  subject { described_class.new(client) }

  describe '#query' do
    it 'sends prometheus query' do
      query = 'sum by(verdict) (increase(hubble_flows_processed_total[1w]))'
      subject.query
      expect(client).to have_received(:query).with(query)
    end

    it 'returns metrics' do
      result = subject.query
      expect(result).to match(forwards: 73772, drops: 5)
    end
  end
end
