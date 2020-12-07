# frozen_string_literal: true

module Elastic
  module MigrationLaunchOptions
    LAUNCH_OPTIONS_EXPIRE_IN = 1.day

    def launch_options
      with_redis do |redis|
        value = redis.get(redis_key)

        Gitlab::Json.parse(value).with_indifferent_access if value
      end
    end

    def set_launch_options(options)
      log "Setting launch_options to #{options}"
      with_redis do |redis|
        redis.set(redis_key, options.to_json, ex: LAUNCH_OPTIONS_EXPIRE_IN)
      end
    end

    private

    def with_redis
      ::Gitlab::Redis::SharedState.with { |redis| yield redis }
    end

    def redis_key
      "elastic:migration:#{version}:launch_options"
    end
  end
end
