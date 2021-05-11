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

        # Always uses replicas disallowing writes
        def self.read_only(&blk)
          with_new_session do |session|
            session.read_only!

            yield
          end
        end

        # Uses primary to perform isolated write
        # that does not change an overall replica usage
        def self.isolated_write(&blk)
          with_new_session do |session|
            session.use_primary!

            yield
          end
        end

        def self.with_new_session
          previous = RequestStore[CACHE_KEY]
          current = new
          RequestStore[CACHE_KEY] = current

          yield(current)
        ensure
          RequestStore[CACHE_KEY] = previous
        end

        def initialize
          @use_primary = false
          @read_only = false
        end

        def use_primary?
          @use_primary
        end

        def read_only?
          @read_only
        end

        def force_read_only!
          @read_only = true
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

        def write!
          @performed_write = true
          use_primary!
        end

        def performed_write?
          @performed_write
        end

        # In some cases in a read only we want to allow opening transaction
        # making this still forced to be read-only
        def transaction_using_replica?
          @read_only && !@use_primary
        end
      end
    end
  end
end
