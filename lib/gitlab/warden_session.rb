module Gitlab
  class WardenSession
    KEY = 'gitlab.warden_sessions'.freeze

    class << self
      # Save current warden values for later use.
      def save
        current_user_id = session.dig('warden.user.user.key', 0, 0)
        self[current_user_id] = warden_data
      end

      # Load saved warden values to active session.
      def load(user_id)
        session.merge! self[user_id]
      end

      def users
        User.where(id: saved.keys)
      end

      # # Remove all warden values from the session.
      # def clean
      #   warden_keys.each { |key| session.delete(key) }
      # end

      private

      def []=(key, val)
        saved ||= {}
        saved[key] = val
      end

      def [](key)
        session.dig(KEY, key)
      end

      def delete(key)
        saved.delete(key) if saved
      end

      # A slice of all warden data.
      def warden_data
        session.to_h.slice(*warden_keys)
      end

      def warden_keys
        session.keys.grep(/warden\./)
      end

      def session
        Gitlab::Session.current
      end

      def saved
        session[KEY]
      end
    end
  end
end
