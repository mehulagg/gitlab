# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :elastic) do
    helper = Gitlab::Elastic::Helper.default
    @migrations_index_name = helper.migrations_index_name

    Elastic::ProcessBookkeepingService.clear_tracking!

    helper.delete_index(index_name: @migrations_index_name)
    helper.delete_index

    helper.create_empty_index(options: { settings: { number_of_replicas: 0 } })
    helper.create_migrations_index
  end

  config.after(:each, :elastic) do
    helper = Gitlab::Elastic::Helper.default

    helper.delete_index
    helper.delete_index(index_name: @migrations_index_name)

    Elastic::ProcessBookkeepingService.clear_tracking!
  end

  config.include ElasticsearchHelpers, :elastic
end
