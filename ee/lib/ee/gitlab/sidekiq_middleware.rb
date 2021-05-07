# frozen_string_literal: true

module EE
  module Gitlab
    # The SidekiqMiddleware class is responsible for configuring the
    # middleware stacks used in the client and server middlewares
    module SidekiqMiddleware
      extend ::Gitlab::Utils::Override

      override :server_configurator
      def server_configurator(metrics: true, arguments_logger: true, memory_killer: true)
        lambda do |chain|
          super.call(chain)

          if load_balancing_enabled?
            chain.insert_after(::Gitlab::SidekiqMiddleware::InstrumentationLogger,
                               ::Gitlab::Database::LoadBalancing::SidekiqServerMiddleware)
          end
        end
      end

      override :client_configurator
      def client_configurator
        lambda do |chain|
          super.call(chain)

          chain.add ::Gitlab::Database::LoadBalancing::SidekiqClientMiddleware if load_balancing_enabled?
        end
      end

      private

      def load_balancing_enabled?
        ::Gitlab::Database::LoadBalancing.enable?
      end
    end
  end
end
