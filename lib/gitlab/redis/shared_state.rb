# frozen_string_literal: true

module Gitlab
  module Redis
    class SharedState < ::Gitlab::Redis::Wrapper
      SESSION_NAMESPACE = 'session:gitlab'
      USER_SESSIONS_NAMESPACE = 'session:user:gitlab'
      USER_SESSIONS_LOOKUP_NAMESPACE = 'session:lookup:user:gitlab'
      IP_SESSIONS_LOOKUP_NAMESPACE = 'session:lookup:ip:gitlab2'

      private

      def raw_config_hash
        super || { url: 'redis://localhost:6382' }
      end
    end
  end
end
