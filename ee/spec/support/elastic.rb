# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :elastic) do |example|
    Elastic::ProcessBookkeepingService.clear_tracking!
    Gitlab::Elastic::Helper.default.delete_index
    Gitlab::Elastic::Helper.default.create_empty_index(options: { settings: { number_of_replicas: 0 } })

    name_inspector = ElasticQueryNameInspector.new
    es_config = Gitlab::CurrentSettings.elasticsearch_config
    es_client = Gitlab::Elastic::Client.build(es_config) do |faraday|
      faraday.use(ElasticQueryInspectorMiddleware, inspector: name_inspector)
    end

    example.metadata[:query_inspector] = name_inspector

    # inject a client that records Elastic named queries
    GemExtensions::Elasticsearch::Model::Client.cached_client = es_client
    GemExtensions::Elasticsearch::Model::Client.cached_config = es_config
  end

  config.after(:each, :elastic) do
    Gitlab::Elastic::Helper.default.delete_index
    Elastic::ProcessBookkeepingService.clear_tracking!
  end

  config.include ElasticsearchHelpers, :elastic
end
