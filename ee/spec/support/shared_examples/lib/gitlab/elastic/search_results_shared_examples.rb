# frozen_string_literal: true

RSpec.shared_examples 'does not hit Elasticsearch twice for objects and counts' do |scopes|
  scopes.each do |scope|
    context "for scope #{scope}", :elastic, :request_store do
      it 'makes 1 Elasticsearch query' do
        # We want to warm the cache for checking migrations have run since we
        # don't want to count these requests as searches
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
        warm_elasticsearch_migrations_cache!
        ::Gitlab::SafeRequestStore.clear!

        results.objects(scope)
        results.public_send("#{scope}_count")

        expect(::Gitlab::Instrumentation::ElasticsearchTransport.get_request_count).to eq(1)
      end
    end
  end
end

RSpec.shared_examples 'does not load results for count only queries' do |scopes|
  scopes.each do |scope|
    before do
      allow(::Gitlab::PerformanceBar).to receive(:enabled_for_request?).and_return(true)
    end

    context "for scope #{scope}", :elastic, :request_store do
      it 'makes count query' do
        # We want to warm the cache for checking migrations have run since we
        # don't want to count these requests as searches
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
        warm_elasticsearch_migrations_cache!
        ::Gitlab::SafeRequestStore.clear!

        results.public_send("#{scope}_count")

        request = ::Gitlab::Instrumentation::ElasticsearchTransport.detail_store.first

        expect(request.dig(:body, :size)).to eq(0)
        expect(request.dig(:body, :query, :bool, :must)).to be_blank
        expect(request[:highlight]).to be_blank
      end
    end
  end
end
