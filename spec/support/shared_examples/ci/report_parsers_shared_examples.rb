# frozen_string_literal: true

RSpec.shared_examples 'instrumented report parser' do
  it 'sets metrics for duration of parsing' do
    parse_report

    metrics = Gitlab::Metrics.registry.get(:ci_report_parser_duration_seconds).get({ parser: described_class.name })

    expect(metrics.keys).to match_array(Prometheus::Client::Histogram::DEFAULT_BUCKETS)
  end
end
