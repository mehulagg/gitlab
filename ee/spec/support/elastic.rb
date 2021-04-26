# frozen_string_literal: true

# rubocop:disable Rails/TimeZone
RSpec.configure do |config|
  config.before(:context, :elastic) do
    puts "[#{Time.now}] :elastic start"
    helper = Gitlab::Elastic::Helper.default

    Elastic::ProcessBookkeepingService.clear_tracking!
    puts "[#{Time.now}] :elastic tracking cleared!"

    # Delete all test indices
    indices = [helper.target_name, helper.migrations_index_name] + helper.standalone_indices_proxies.map(&:index_name)
    indices.each do |index_name|
      helper.delete_index(index_name: index_name)
      puts "[#{Time.now}] #{index_name} deleted!"
    end

    helper.create_empty_index(options: { settings: { number_of_replicas: 0 } })
    puts "[#{Time.now}] empty index created!"
    helper.create_migrations_index
    ::Elastic::DataMigrationService.mark_all_as_completed!
    puts "[#{Time.now}] data migration service completed!"
    helper.create_standalone_indices
    puts "[#{Time.now}] standalone indices created!"
    refresh_index!
    puts "[#{Time.now}] index refreshed!"
  end

  config.after(:context, :elastic) do
    puts "[#{Time.now}] example ran!"

    indices.each do |index_name|
      helper.delete_index(index_name: index_name)
      puts "[#{Time.now}] #{index_name} deleted!"
    end
    Elastic::ProcessBookkeepingService.clear_tracking!
    puts "[#{Time.now}] :elastic tracking cleared!"
  end

  config.include ElasticsearchHelpers, :elastic
end
# rubocop:enable Rails/TimeZone
