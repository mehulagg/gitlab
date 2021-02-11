# frozen_string_literal: true

module WebEngine
  class Engine < ::Rails::Engine
    initializer :before_set_eager_paths, before: :set_load_path do |app|
      config.eager_load_paths.push(*%W[#{config.root}/lib
                                       #{config.root}/app/graphql/resolvers/concerns
                                       #{config.root}/app/graphql/mutations/concerns
                                       #{config.root}/app/graphql/types/concerns])

      app.config.paths['draw_routes'] << 'engines/web_engine/config/routes'

      if Gitlab.ee?
        app.config.paths['draw_routes'] << 'engines/web_engine/ee/config/routes'

        ee_paths = config.eager_load_paths.each_with_object([]) do |path, memo|
          ee_path = config.root
                      .join('ee', Pathname.new(path).relative_path_from(config.root))
          memo << ee_path.to_s
        end
        # Eager load should load CE first
        config.eager_load_paths.push(*ee_paths)
      end
    end

    initializer :engine_load_config_initializers, after: :load_config_initializers do
      Dir[WebEngine::Engine.root.join('config/initializers_after_application/*.rb')].sort.each do |initializer|
        load_config_initializer(initializer)
      end
    end
  end
end
