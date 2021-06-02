# frozen_string_literal: true

module Gitlab
  module Database
    module PostgresqlAdapter
      module ForceDisconnectableMixin
        extend ActiveSupport::Concern

        prepended do
          set_callback :checkin, :after, :force_disconnect_if_old!
        end

        def force_disconnect_if_old!
          if primary_connection? && force_disconnect_timer.expired?
            disconnect!
            reset_force_disconnect_timer!
          end
        end

        def primary_connection?
          Gitlab::Database::LoadBalancing.db_role_for_connection(self) == :primary
        end

        def reset_force_disconnect_timer!
          force_disconnect_timer.reset!
        end

        def force_disconnect_timer
          @force_disconnect_timer ||= ConnectionTimer.starting_now
        end
      end
    end
  end
end
