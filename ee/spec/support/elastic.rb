# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, :elastic) do |example|
    helper = Gitlab::Elastic::Helper.default

    Elastic::ProcessBookkeepingService.clear_tracking!

    # Delete all test indices
    indices = [helper.target_name, helper.migrations_index_name] + helper.standalone_indices_proxies.map(&:index_name)
    indices.each do |index_name|
      helper.delete_index(index_name: index_name)
    end

    helper.create_empty_index(options: { settings: { number_of_replicas: 0 } })
    helper.create_migrations_index
    ::Elastic::DataMigrationService.mark_all_as_completed!
    helper.create_standalone_indices
    refresh_index!

    example.run

    indices.each do |index_name|
      helper.delete_index(index_name: index_name)
    end
    Elastic::ProcessBookkeepingService.clear_tracking!
  end

  config.include ElasticsearchHelpers, :elastic
end
