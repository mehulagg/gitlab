# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Prometheus::Queries::PacketFlowQuery do
  let(:namespace) { 'query-12345678-production' }
  let(:query_range_response) { [] }
  let(:query_response) { [] }
  let(:client) { double('prometheus_client', query: query_response, query_range: query_range_response) }

  subject { described_class.new(client) }

  context 'metrics' do
    let(:query_range_response) do
      [
        { "metric" => { "verdict" => "FORWARDED" }, "values" => [[1582231596.64, "73772.43143284984"]] },
        { "metric" => { "verdict" => "DROPPED" }, "values" => [[1582231596.64, "5.002730665588791"]] }
      ]
    end

    let(:query_response) do
      [
        { "metric" => { "verdict" => "FORWARDED" }, "value" => [1582231596.64, "73772.43143284984"] },
        { "metric" => { "verdict" => "DROPPED" }, "value" => [1582231596.64, "5.002730665588791"] }
      ]
    end

    let(:result) { subject.query(namespace) }

    it 'returns ops_rate metric' do
      expect(result[:ops_rate]).to(
        eq(
          {
            total: [[1582231596.64, 73777.43416351543]],
            drops: [[1582231596.64, 5.002730665588791]]
          }
        )
      )
    end

    it 'returns ops_total metric' do
      expect(result[:ops_total]).to eq({ total: 73777, drops: 5 })
    end
  end

  context 'query' do
    it 'sends ops_rate prometheus query' do
      query = 'sum by(verdict) (' \
              'rate(hubble_flows_processed_total{destination="query-12345678-production"}[1h])' \
              ' or on(source,destination,verdict) ' \
              'rate(hubble_flows_processed_total{source="query-12345678-production"}[1h]))'
      expect(client).to receive(:query_range).with(query, any_args)
      subject.query(namespace)
    end

    it 'sends ops_total prometheus query' do
      query = 'sum by(verdict) (' \
              'increase(hubble_flows_processed_total{destination="query-12345678-production"}[86400s])' \
              ' or on(source,destination,verdict) ' \
              'increase(hubble_flows_processed_total{source="query-12345678-production"}[86400s]))'
      expect(client).to receive(:query).with(query, any_args)
      subject.query(namespace)
    end
  end

  context 'ops_rate intervals' do
    { "minute" => "5m", "hour" => "1h", "day" => "1d" }.each do |interval, value|
      context "#{interval} interval" do
        it 'uses correct interval' do
          query = 'sum by(verdict) (' \
                  "rate(hubble_flows_processed_total{destination=\"query-12345678-production\"}[#{value}])" \
                  ' or on(source,destination,verdict) ' \
                  "rate(hubble_flows_processed_total{source=\"query-12345678-production\"}[#{value}]))"
          expect(client).to receive(:query_range).with(query, any_args)
          subject.query(namespace, interval)
        end
      end
    end
  end

  context 'time range' do
    let(:from) { Time.at(0) }
    let(:to) { Time.at(100) }

    context 'ops_rate query' do
      it 'sets query time range' do
        expect(client).to receive(:query_range).with(anything, start_time: from, end_time: to)
        subject.query(namespace, 'hour', from.to_s, to.to_s)
      end
    end

    context 'ops_total query' do
      it 'sets query time range and interval' do
        query = 'sum by(verdict) (' \
                'increase(hubble_flows_processed_total{destination="query-12345678-production"}[100s])' \
                ' or on(source,destination,verdict) ' \
                'increase(hubble_flows_processed_total{source="query-12345678-production"}[100s]))'
        expect(client).to receive(:query).with(query, time: to)
        subject.query(namespace, 'hour', from.to_s, to.to_s)
      end
    end
  end
end
