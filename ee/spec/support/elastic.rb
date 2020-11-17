# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :elastic) do
    Elastic::ProcessBookkeepingService.clear_tracking!
    Gitlab::Elastic::Helper.default.delete_index
    Gitlab::Elastic::Helper.default.create_empty_index(options: { settings: { number_of_replicas: 0 } })
    @migrations_index_name = Gitlab::Elastic::Helper.default.create_migrations_index
  end

  config.after(:each, :elastic) do
    Gitlab::Elastic::Helper.default.delete_index
    Elastic::ProcessBookkeepingService.clear_tracking!
    Gitlab::Elastic::Helper.default.delete_index(index_name: @migrations_index_name)
  end

  config.include ElasticsearchHelpers, :elastic
end
