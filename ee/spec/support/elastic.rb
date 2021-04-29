# frozen_string_literal: true

class ElasticTestHelpers # rubocop:disable Gitlab/NamespacedClass
  include ElasticsearchHelpers

  def helper
    @helper ||= Gitlab::Elastic::Helper.default
  end

  def indices
    @indices ||= [helper.target_name, helper.migrations_index_name] + helper.standalone_indices_proxies.map(&:index_name)
  end

  def setup
    clear_tracking!
    delete_indices!
    measure('create_empty_index') { helper.create_empty_index(options: { settings: { number_of_replicas: 0 } }) }
    measure('create_migrations_index') { helper.create_migrations_index }
    measure('mark_all_as_completed') { ::Elastic::DataMigrationService.mark_all_as_completed! }
    measure('create_standalone_indices') { helper.create_standalone_indices }
    refresh_elasticsearch_index!
  end

  def teardown
    delete_indices!
    clear_tracking!
  end

  def clear_tracking!
    measure('clear_tracking') { Elastic::ProcessBookkeepingService.clear_tracking! }
  end

  def refresh_elasticsearch_index!
    measure('refresh_index') { refresh_index! }
  end

  def delete_indices!
    measure('delete_indices') do
      indices.each do |index_name|
        helper.delete_index(index_name: index_name)
      end
    end
  end

  def measure(task)
    real_start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)

    yield.tap do
      puts "Done '#{task}' in #{(Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second) - real_start).round(2)} seconds" if ENV['CI'] || ENV['TIME_ES_SETUP']
    end
  end

  def delete_all_data_from_index!
    measure('delete_all_data_from_index') do
      helper.client.delete_by_query(
        {
          index: indices,
          body: { query: { match_all: {} } },
          slices: 5,
          conflicts: 'proceed'
        }
      )
    end
  end
end

RSpec.configure do |config|
  config.around(:each, :elastic) do |example|
    helper = ElasticTestHelpers.new
    helper.setup

    example.run

    helper.teardown
  end

  config.before(:context, :elastic_context) do
    ElasticTestHelpers.new.setup
  end

  config.after(:context, :elastic_context) do
    ElasticTestHelpers.new.teardown
  end

  config.before(:context, :elastic_test) do
    ElasticTestHelpers.new.setup
  end

  config.after(:context, :elastic_test) do
    ElasticTestHelpers.new.teardown
  end

  config.around(:each, :elastic_test) do |example|
    helper = ElasticTestHelpers.new
    helper.refresh_elasticsearch_index!

    example.run

    helper.delete_all_data_from_index!
  end

  config.include ElasticsearchHelpers, :elastic
  config.include ElasticsearchHelpers, :elastic_context
  config.include ElasticsearchHelpers, :elastic_test
end
