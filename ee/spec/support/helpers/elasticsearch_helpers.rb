# frozen_string_literal: true

module ElasticsearchHelpers
  def expect_named_queries(example, &block)
    query_inspector = example.metadata[:query_inspector]
    query_inspector.reset!

    yield query_inspector

    expect(query_inspector.names).not_to be_empty
    expect(query_inspector.names).not_to include(be_empty)
  end

  def ensure_elasticsearch_index!
    # Ensure that any enqueued updates are processed
    Elastic::ProcessBookkeepingService.new.execute
    Elastic::ProcessInitialBookkeepingService.new.execute

    # Make any documents added to the index visible
    refresh_index!
  end

  def refresh_index!
    ::Gitlab::Elastic::Helper.default.refresh_index
  end
end
