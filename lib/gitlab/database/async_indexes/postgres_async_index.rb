# frozen_string_literal: true

module Gitlab
  module Database
    module AsyncIndexes
      class PostgresAsyncIndex < ActiveRecord::Base
        self.table_name = 'postgres_async_indexes'

        def to_s
          definition
        end
      end
    end
  end
end
