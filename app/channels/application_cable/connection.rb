# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_current_user
    end

    private

    def find_current_user
      raw_session = Gitlab::Redis::SharedState.with { |redis| redis.get("#{Gitlab::Redis::SharedState::SESSION_NAMESPACE}:#{session_id}") }
      return unless raw_session

      data = Marshal.load(raw_session) # rubocop:disable Security/MarshalLoad
      user_id = data['warden.user.user.key']&.first

      User.find_by_id(user_id) if user_id
    end

    def session_id
      cookies[Gitlab::Application.config.session_options[:key]]
    end
  end
end
