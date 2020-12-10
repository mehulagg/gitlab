# frozen_string_literal: true

# ActiveRecord uses `SELECT 1` to check if the connection is alive
# We patch this here to use an empty query instead, which is a bit faster
module ActiveRecord
  module ConnectionHandling
    module ConnectionAdapters
      class PostgreSQLAdapter
        def active?
          @lock.synchronize do
            @connection.query ";"
          end
          true
        rescue PG::Error
          false
        end
      end
    end
  end
end
