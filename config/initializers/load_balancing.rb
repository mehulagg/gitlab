# frozen_string_literal: true

# We need to run this initializer after migrations are done so it doesn't fail on CI

Gitlab.ee do
  if Gitlab::Database.cached_table_exists?('licenses')
    if Gitlab::Database::LoadBalancing.enable?
      Gitlab::Database.disable_prepared_statements

      Gitlab::Application.configure do |config|
        config.middleware.use(Gitlab::Database::LoadBalancing::RackMiddleware)
      end

      Gitlab::Database::LoadBalancing.configure_proxy

      if Gitlab::Database::LoadBalancing.load_balancing_for_sidekiq?
        Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.add(Gitlab::Database::LoadBalancing::SidekiqServerMiddleware)
          end
        end

        Sidekiq.configure_client do |config|
          config.client_middleware do |chain|
            chain.add(Gitlab::Database::LoadBalancing::SidekiqClientMiddleware)
          end
        end
      end

      # This needs to be executed after fork of clustered processes
      Gitlab::Cluster::LifecycleEvents.on_worker_start do
        # Service discovery must be started after configuring the proxy, as service
        # discovery depends on this.
        Gitlab::Database::LoadBalancing.start_service_discovery
      end

    end
  end
end
