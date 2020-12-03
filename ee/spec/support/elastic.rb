# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, :elastic) do |example|
    helper = Gitlab::Elastic::Helper.default

    Elastic::ProcessBookkeepingService.clear_tracking!

    # Delete the migration index and the main ES index
    helper.delete_index(index_name: helper.migrations_index_name)
    helper.delete_index

    helper.create_empty_index(options: { settings: { number_of_replicas: 0 } })
    helper.create_migrations_index

    example.run

    helper.delete_index(index_name: helper.migrations_index_name)
    helper.delete_index

    Elastic::ProcessBookkeepingService.clear_tracking!
  end

  config.include ElasticsearchHelpers, :elastic
end
