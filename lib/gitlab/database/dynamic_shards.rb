module DynamicShards
  def skip_post_migrate?
    Gitlab::Utils.to_boolean(ENV['SKIP_POST_DEPLOYMENT_MIGRATIONS'], default: false) && !Gitlab::Runtime.rake?
  end

  # This is temporary hack to ensure that we don't affect development envs
  # using this MR, so we append to database name some string
  def database_configuration
    super.to_h do |env, configs|
      # convert '{adapter: postgresql}' to '{main:{adapter: postgresql}}'
      if configs.is_a?(Hash) && !configs.all? { |_, v| v.is_a?(Hash) }
        configs = {"main" => configs}
      end

      # Drop CI if configured if running in a single mode
      if Gitlab::Utils.to_boolean(ENV["FORCE_SINGLE_DB"])
        configs.delete("ci")
      end

      multiple_dbs = configs.include?("ci")

      configs.each do |config_name, config|
        if config_name == 'main'
          # TODO: CI vertical
          # Set to public to see what features break if CI tables were "moved"
          # Set to public,gitlab_ci to restore CI tables again
          #
          config["schema_search_path"] ||=
            if multiple_dbs # limit schema visibility if multiple DBs
              "public,gitlab_shared"
            else
              "public,gitlab_ci,gitlab_shared"
            end

          config["migrations_paths"] ||= db_migration_paths.compact
        elsif config_name == 'ci'
          config["schema_search_path"] ||= "gitlab_ci,gitlab_shared"
          config["migrations_paths"] ||= db_migration_paths("ci_").compact
        end
        config["use_metadata_table"] = false

        # Add suffix for local env
        config["database"] += db_suffix if db_suffix
      end

      [env, configs]
    end
  end

  def db_suffix
    "_poc" unless Gitlab::Utils.to_boolean(ENV['CI'])
  end

  def db_migration_paths(prefix = nil)
    [
      "db/#{prefix}migrate",
      !skip_post_migrate? && "db/#{prefix}post_migrate"
    ].compact
  end
end

Rails::Application::Configuration.prepend(DynamicShards)

ActiveSupport.on_load(:active_record) do
  db_configs = Rails.application.config.database_configuration[Rails.env]
  if db_configs.include?("ci")
    warn "Using multiple databases"
  else
    warn "Using single database"
  end
end
