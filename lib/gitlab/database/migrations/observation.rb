# frozen_string_literal: true

module Gitlab
  module Database
    module Migrations
      Observation = Struct.new(
        :migration_name,
        :migration_version,
        :walltime,
        :success,
        :total_database_size_change,
        :query_statistics,
        keyword_init: true
      )
    end
  end
end
