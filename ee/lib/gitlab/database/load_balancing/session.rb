# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      # Tracking of load balancing state per user session.
      #
      # A session starts at the beginning of a request and ends once the request
      # has been completed. Sessions can be used to keep track of what hosts
      # should be used for queries.
      class Session
        CACHE_KEY = :gitlab_load_balancer_session

        def self.current
          RequestStore[CACHE_KEY] ||= new
        end

        def self.clear_session
          RequestStore.delete(CACHE_KEY)
        end

        def initialize
          @use_primary = false
          @performed_write = false
        end

        def use_primary?
          @use_primary
        end

        alias_method :using_primary?, :use_primary?

        def use_primary!
          @use_primary = true
        end

        def use_primary(&blk)
          used_primary = @use_primary
          @use_primary = true
          yield
        ensure
          @use_primary = used_primary || @performed_write
        end

        # Indicate that all the SQL statements from anywhere inside this block
        # should use a replica. This is a weak enforcement. The queries
        # prioritize using a primary over a replica in those cases:
        # - If the queries are about to write
        # - The current session already performed writes
        # - It prefers to use primary, aka, use_primary or use_primary! were called
        def use_replica_if_possible(&blk)
          return yield if use_primary? || performed_write?

          begin
            used_replica = @use_replica
            @use_replica = true
            yield
          ensure
            @use_replica = used_replica && !use_primary? && !performed_write?
          end
        end

        def use_replica?
          @use_replica == true && !use_primary? && !performed_write?
        end

        def write!
          @performed_write = true
          use_primary!
        end

        def performed_write?
          @performed_write
        end
      end
    end
  end
end
