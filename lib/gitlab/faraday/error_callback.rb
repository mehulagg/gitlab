# frozen_string_literal: true

module Gitlab
  module Faraday
    # Simple Faraday Middleware that catches any error risen during the request and run the configured callback.
    # (https://lostisland.github.io/faraday/middleware/)
    #
    # By default, a no op callback is setup.
    #
    # Note that the error is not swallowed: it will be rerisen again. In that regard, this callback acts more
    # like an error spy than anything else.
    #
    # The callback has access to the request `env` and the exception instance. For more details, see
    # https://lostisland.github.io/faraday/middleware/custom
    #
    # Faraday.new do |conn|
    #   conn.request(
    #     :error_callback,
    #     callback: -> (env, exception) { Rails.logger.debug("Error #{exception.class.name} when trying to contact #{env[:url]}" ) }
    #   )
    #   conn.adapter(:net_http)
    # end
    class ErrorCallback < ::Faraday::Middleware
      def initialize(app, options = nil)
        super(app)
        @options = ::Gitlab::Faraday::ErrorCallback::Options.from(options) # rubocop: disable CodeReuse/ActiveRecord
      end

      def call(env)
        @app.call(env)
      rescue => e
        @options.callback.call(env, e)
        raise
      end

      class Options < ::Faraday::Options.new(:callback)
        DEFAULT_CALLBACK = -> (_env, _exception) { }

        def callback
          self[:callback] || DEFAULT_CALLBACK
        end
      end
    end
  end
end

::Faraday::Request.register_middleware(error_callback: -> { ::Gitlab::Faraday::ErrorCallback })
