# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::WafAnomalySummaryService do
  let(:environment) { create(:environment, :with_review_app, environment_type: 'review') }
  let!(:cluster) do
    create(:cluster, :provided_by_gcp, environment_scope: '*', projects: [environment.project])
  end

  let(:es_client) { double(Elasticsearch::Client) }
  let(:chart_above_v3) { true }

  let(:empty_response) do
    {
      'took' => 40,
      'timed_out' => false,
      '_shards' => { 'total' => 11, 'successful' => 11, 'skipped' => 0, 'failed' => 0 },
      'hits' => { 'total' => { 'value' => 0, 'relation' => 'gte' }, 'max_score' => 0.0, 'hits' => [] },
      'aggregations' => {
        'counts' => {
          'buckets' => []
        }
      },
      'status' => 200
    }
  end

  let(:nginx_response) do
    empty_response.deep_merge(
      'hits' => { 'total' => { 'value' => 3 } },
      'aggregations' => {
        'counts' => {
          'buckets' => [
            { 'key_as_string' => '2020-02-14T23:00:00.000Z', 'key' => 1575500400000, 'doc_count' => 1 },
            { 'key_as_string' => '2020-02-15T00:00:00.000Z', 'key' => 1575504000000, 'doc_count' => 0 },
            { 'key_as_string' => '2020-02-15T01:00:00.000Z', 'key' => 1575507600000, 'doc_count' => 0 },
            { 'key_as_string' => '2020-02-15T08:00:00.000Z', 'key' => 1575532800000, 'doc_count' => 2 }
          ]
        }
      }
    )
  end

  let(:modsec_response) do
    empty_response.deep_merge(
      'hits' => { 'total' => { 'value' => 1 } },
      'aggregations' => {
        'counts' => {
          'buckets' => [
            { 'key_as_string' => '2019-12-04T23:00:00.000Z', 'key' => 1575500400000, 'doc_count' => 0 },
            { 'key_as_string' => '2019-12-05T00:00:00.000Z', 'key' => 1575504000000, 'doc_count' => 0 },
            { 'key_as_string' => '2019-12-05T01:00:00.000Z', 'key' => 1575507600000, 'doc_count' => 0 },
            { 'key_as_string' => '2019-12-05T08:00:00.000Z', 'key' => 1575532800000, 'doc_count' => 1 }
          ]
        }
      }
    )
  end

  let(:nginx_response_es6) do
    empty_response.deep_merge(
      'hits' => { 'total' => 3 },
      'aggregations' => {
        'counts' => {
          'buckets' => [
            { 'key_as_string' => '2020-02-14T23:00:00.000Z', 'key' => 1575500400000, 'doc_count' => 1 },
            { 'key_as_string' => '2020-02-15T00:00:00.000Z', 'key' => 1575504000000, 'doc_count' => 0 },
            { 'key_as_string' => '2020-02-15T01:00:00.000Z', 'key' => 1575507600000, 'doc_count' => 0 },
            { 'key_as_string' => '2020-02-15T08:00:00.000Z', 'key' => 1575532800000, 'doc_count' => 2 }
          ]
        }
      }
    )
  end

  let(:modsec_response_es6) do
    empty_response.deep_merge(
      'hits' => { 'total' => 1 },
      'aggregations' => {
        'counts' => {
          'buckets' => [
            { 'key_as_string' => '2019-12-04T23:00:00.000Z', 'key' => 1575500400000, 'doc_count' => 0 },
            { 'key_as_string' => '2019-12-05T00:00:00.000Z', 'key' => 1575504000000, 'doc_count' => 0 },
            { 'key_as_string' => '2019-12-05T01:00:00.000Z', 'key' => 1575507600000, 'doc_count' => 0 },
            { 'key_as_string' => '2019-12-05T08:00:00.000Z', 'key' => 1575532800000, 'doc_count' => 1 }
          ]
        }
      }
    )
  end

  subject { described_class.new(environment: environment) }

  describe '#execute' do
    context 'without cluster' do
      before do
        allow(environment).to receive(:deployment_platform) { nil }
      end

      it 'returns no results' do
        expect(subject.execute).to be_nil
      end
    end

    context 'without elastic_stack' do
      it 'returns no results' do
        expect(subject.execute).to be_nil
      end
    end

    context 'with environment missing external_url' do
      before do
        allow(environment.deployment_platform.cluster).to receive_message_chain(
          :integration_elastic_stack, :elasticsearch_client
        ) { es_client }

        allow(environment).to receive(:external_url) { nil }
      end

      it 'returns nil' do
        expect(subject.execute).to be_nil
      end
    end

    context 'with default histogram' do
      before do
        allow(es_client).to receive(:msearch) do
          { 'responses' => [nginx_results, modsec_results] }
        end

        allow(environment.deployment_platform.cluster).to receive_message_chain(
          :integration_elastic_stack, :elasticsearch_client
        ) { es_client }
        allow(environment.deployment_platform.cluster).to receive_message_chain(
          :integration_elastic_stack, :chart_above_v3?
        ) { chart_above_v3 }
      end

      context 'no requests' do
        let(:nginx_results) { empty_response }
        let(:modsec_results) { empty_response }

        it 'returns results', :aggregate_failures do
          results = subject.execute

          expect(results.fetch(:status)).to eq :success
          expect(results.fetch(:interval)).to eq 'day'
          expect(results.fetch(:total_traffic)).to eq 0
          expect(results.fetch(:anomalous_traffic)).to eq 0.0
        end

        context 'when totals_only is set to true' do
          it 'returns totals only', :aggregate_failures do
            results = subject.execute(totals_only: true)

            expect(results).to eq(total_traffic: 0.0, total_anomalous_traffic: 0.0)
          end
        end
      end

      context 'no violations' do
        let(:nginx_results) { nginx_response }
        let(:modsec_results) { empty_response }

        it 'returns results', :aggregate_failures do
          results = subject.execute

          expect(results.fetch(:status)).to eq :success
          expect(results.fetch(:interval)).to eq 'day'
          expect(results.fetch(:total_traffic)).to eq 3
          expect(results.fetch(:anomalous_traffic)).to eq 0.0
        end

        context 'when totals_only is set to true' do
          it 'returns totals only', :aggregate_failures do
            results = subject.execute(totals_only: true)

            expect(results).to eq(total_traffic: 3.0, total_anomalous_traffic: 0.0)
          end
        end
      end

      context 'with violations' do
        let(:nginx_results) { nginx_response }
        let(:modsec_results) { modsec_response }

        it 'returns results', :aggregate_failures do
          results = subject.execute

          expect(results.fetch(:status)).to eq :success
          expect(results.fetch(:interval)).to eq 'day'
          expect(results.fetch(:total_traffic)).to eq 3
          expect(results.fetch(:anomalous_traffic)).to eq 0.33
        end

        context 'when totals_only is set to true' do
          it 'returns totals only', :aggregate_failures do
            results = subject.execute(totals_only: true)

            expect(results).to eq(total_traffic: 3.0, total_anomalous_traffic: 1.0)
          end
        end
      end

      context 'with legacy es6 cluster' do
        let(:chart_above_v3) { false }

        let(:nginx_results) { nginx_response_es6 }
        let(:modsec_results) { modsec_response_es6 }

        it 'returns results', :aggregate_failures do
          results = subject.execute

          expect(results.fetch(:status)).to eq :success
          expect(results.fetch(:interval)).to eq 'day'
          expect(results.fetch(:total_traffic)).to eq 3
          expect(results.fetch(:anomalous_traffic)).to eq 0.33
        end
      end
    end

    context 'with review app' do
      it 'resolves transaction_id from external_url' do
        allow(subject).to receive(:elasticsearch_client) { es_client }
        allow(subject).to receive(:chart_above_v3?) { chart_above_v3 }

        expect(es_client).to receive(:msearch).with(
          body: array_including(
            hash_including(
              query: hash_including(
                bool: hash_including(
                  must: array_including(
                    hash_including(
                      prefix: hash_including(
                        'transaction.unique_id': environment.formatted_external_url
                      )
                    )
                  )
                )
              )
            )
          )
        ).and_return({ 'responses' => [{}, {}] })

        subject.execute
      end
    end

    context 'with time window' do
      it 'passes time frame to ElasticSearch' do
        from = 1.day.ago
        to = Time.current

        subject = described_class.new(
          environment: environment,
          from: from,
          to: to
        )

        allow(subject).to receive(:elasticsearch_client) { es_client }
        allow(subject).to receive(:chart_above_v3?) { chart_above_v3 }

        expect(es_client).to receive(:msearch).with(
          body: array_including(
            hash_including(
              query: hash_including(
                bool: hash_including(
                  must: array_including(
                    hash_including(
                      range: hash_including(
                        '@timestamp' => {
                          gte: from,
                          lte: to
                        }
                      )
                    )
                  )
                )
              )
            )
          )
        ).and_return({ 'responses' => [{}, {}] })

        subject.execute
      end
    end

    context 'with interval' do
      it 'passes interval to ElasticSearch' do
        interval = 'hour'

        subject = described_class.new(
          environment: environment,
          interval: interval
        )

        allow(subject).to receive(:elasticsearch_client) { es_client }
        allow(subject).to receive(:chart_above_v3?) { chart_above_v3 }

        expect(es_client).to receive(:msearch).with(
          body: array_including(
            hash_including(
              aggs: hash_including(
                counts: hash_including(
                  date_histogram: hash_including(
                    interval: interval
                  )
                )
              )
            )
          )
        ).and_return({ 'responses' => [{}, {}] })

        subject.execute
      end
    end
  end
end
