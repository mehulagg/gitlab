# frozen_string_literal: true

require 'spec_helper'

# We don't want to interact with Elasticsearch in GitLab FOSS so we test
# this in ee/ only. The code exists in FOSS and won't do anything.

RSpec.describe ::Gitlab::Instrumentation::ElasticsearchTransport, :elastic, :request_store do
  describe '.increment_request_count' do
    it 'increases the request count by 1' do
      expect { described_class.increment_request_count }.to change(described_class, :get_request_count).by(1)
    end
  end

  describe '.add_duration' do
    it 'does not lose precision while adding' do
      ::Gitlab::SafeRequestStore.clear!

      precision = 1.0 / (10**::Gitlab::InstrumentationHelper::DURATION_PRECISION)
      2.times { described_class.add_duration(0.4 * precision) }

      # 2 * 0.4 should be 0.8 and get rounded to 1
      expect(described_class.query_time).to eq(1 * precision)
    end
  end

  describe '.add_call_details' do
    before do
      stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
      allow(::Gitlab::PerformanceBar).to receive(:enabled_for_request?).and_return(true)
    end

    it 'parses and tracks the call details' do
      ensure_elasticsearch_index!

      ::Gitlab::SafeRequestStore.clear!

      create(:merge_request, title: "new MR")
      ensure_elasticsearch_index!

      request = ::Gitlab::Instrumentation::ElasticsearchTransport.detail_store.first
      expect(request[:method]).to eq("POST")
      expect(request[:path]).to eq("_bulk")
    end
  end
end

RSpec.describe ::Gitlab::Instrumentation::ElasticsearchTransportInterceptor, :elastic, :request_store do
  before do
    allow(::Gitlab::PerformanceBar).to receive(:enabled_for_request?).and_return(true)
  end

  it 'tracks any requests via the Elasticsearch client' do
    ensure_elasticsearch_index!

    expect(::Gitlab::Instrumentation::ElasticsearchTransport.get_request_count).to be > 0
    expect(::Gitlab::Instrumentation::ElasticsearchTransport.query_time).to be > 0
    expect(::Gitlab::Instrumentation::ElasticsearchTransport.detail_store).not_to be_empty
  end

  it 'adds the labkit correlation id as X-Opaque-Id to all requests' do
    allow(Labkit::Correlation::CorrelationId).to receive(:current_or_new_id).and_return('new-correlation-id')

    elasticsearch_url = Gitlab::CurrentSettings.elasticsearch_url[0]
    stub_request(:any, elasticsearch_url)

    Project.__elasticsearch__.client
      .perform_request(:get, '/')

    expect(a_request(:get, /#{elasticsearch_url}/)
      .with(headers: { 'X-Opaque-Id' => 'new-correlation-id' })).to have_been_made
  end

  it 'does not override the X-Opaque-Id if it is already present' do
    allow(Labkit::Correlation::CorrelationId).to receive(:current_or_new_id).and_return('new-correlation-id')

    elasticsearch_url = Gitlab::CurrentSettings.elasticsearch_url[0]
    stub_request(:any, elasticsearch_url)

    Project.__elasticsearch__.client
      .perform_request(:get, '/', {}, nil, { 'X-Opaque-Id': 'original-opaque-id' })

    expect(a_request(:get, /#{elasticsearch_url}/)
      .with(headers: { 'X-Opaque-Id' => 'original-opaque-id' })).to have_been_made
  end
end
