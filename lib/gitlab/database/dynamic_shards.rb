module DynamicShards
  # This is temporary hack to ensure that we don't affect development envs
  # using this MR, so we append to database name some string
  def database_configuration
    super.to_h do |env, configs|
      # convert '{adapter: postgresql}' to '{main:{adapter: postgresql}}'
      if configs.is_a?(Hash) && !configs.all? { |_, v| v.is_a?(Hash) }
        configs = {"main" => configs}
      end

      configs.each do |config_name, config|
        if config_name == 'main'
          # TODO: CI vertical
          # Set to public to see what features break if CI tables were "moved"
          # Set to public,gitlab_ci to restore CI tables again
          #
          config["schema_search_path"] ||= "public,gitlab_ci"
          # config["schema_search_path"] ||= "public"
        elsif config_name == 'ci'
          #config["schema_search_path"] ||= "gitlab_ci"
          config["migrations_paths"] ||= "db/ci_migrate"
        end

        # Hack for CI tests to ensure that we always have `gitlabhq_test` since code depends on it...
        next if Gitlab::Utils.to_boolean(ENV['CI']) && config_name == 'main'

        config["database"] += "_poc"
      end

      [env, configs]
    end
  end
end

Rails::Application::Configuration.prepend(DynamicShards)
