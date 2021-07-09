# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      ProxyNotConfiguredError = Class.new(StandardError)

      # Module injected into ActiveRecord::Base to allow hijacking of the
      # "connection" method.
      module ActiveRecordProxy
        attr_accessor :proxy

        def connection
          unless proxy = ::ActiveRecord::Base.proxy
            ::Gitlab::ErrorTracking.track_exception(
              ::Gitlab::Database::LoadBalancing::ProxyNotConfiguredError.new(
                "Attempting to access the database load balancing proxy, but it wasn't configured.\n" \
                "Did you forget to call 'Gitlab::Database::LoadBalancing.configure_proxy'?"
              ))
          end

          proxy
        end
      end
    end
  end
end
