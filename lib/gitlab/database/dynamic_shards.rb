module DynamicShards
  def database_configuration
    super.to_h do |env, config|
      if config.is_a?(Hash) && config.all? { |_, v| v.is_a?(Hash) }
        # if all hash, it means that this is new multi-database spec
        # activerecord/lib/active_record/database_configurations.rb:123
        next config
      end

      shards = {
        "primary" => config.merge(database: "#{config["database"]}_primary"),
        "ci" => config.merge(database: "#{config["database"]}_ci")
      }

      [env, shards]
    end
  end
end

Rails::Application::Configuration.prepend(DynamicShards)
