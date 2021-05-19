module DynamicShards
  def database_configuration
    puts "Dynamic Shards"

    super.to_h do |env, config|
      if config.is_a?(Hash) && config.all? { |_, v| v.is_a?(Hash) }
        # if all hash, it means that this is new multi-database spec
        # activerecord/lib/active_record/database_configurations.rb:123
        next config
      end

      # Hack for CI tests to ensure that we always have `gitlabhq_test` since code depends on it...
      primary_db = config["database"] == "gitlabhq_test" ? "gitlabhq_test" : "#{config["database"]}_primary"

      shards = {
        "primary" => config.merge(
          database: primary_db
        ),
        "ci" => config.merge(
          database: "#{config["database"]}_ci",
          migrations_paths: "db/migrate_ci"
        )
      }

      [env, shards]
    end
  end
end

Rails::Application::Configuration.prepend(DynamicShards)
