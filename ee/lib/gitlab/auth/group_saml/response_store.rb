# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class ResponseStore
        STORAGE_KEY = 'last_saml_debug_response'
        REDIS_EXPIRY_TIME = 5.minutes

        attr_reader :session_id

        def initialize(session_id)
          @session_id = session_id
        end

        def set_raw(value)
          Gitlab::Redis::SharedState.with { |redis| redis.set(redis_key, value, ex: REDIS_EXPIRY_TIME) }
        end

        def get_raw
          Gitlab::Redis::SharedState.with do |redis|
            response = redis.get(redis_key)
            redis.del(redis_key)

            response
          end
        end

        private

        def redis_key
          "#{STORAGE_KEY}:#{session_id}"
        end
      end
    end
  end
end
