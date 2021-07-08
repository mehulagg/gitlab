# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Class that will populate the new project_search_tokens table for each project
    class BackfillProjectSearchTokens
      BATCH_SIZE = 1_000

      def perform(start_id, stop_id)
        (start_id..stop_id).step(BATCH_SIZE).each do |offset|
          insert_project_search_tokens(offset, offset + BATCH_SIZE)
        end
      end

      private

      def execute(sql)
        @connection ||= ::ActiveRecord::Base.connection
        @connection.execute(sql)
      end

      def insert_project_search_tokens(batch_start, batch_stop)
        execute(<<~SQL)
          INSERT INTO project_search_tokens (project_id, tokens)
            SELECT projects.id, (setweight(to_tsvector(projects.path), 'A') || setweight(to_tsvector(projects.name), 'B'))
            FROM projects
            WHERE projects.id BETWEEN #{batch_start} AND #{batch_stop}
          ON CONFLICT (project_id) DO NOTHING;
        SQL
      end
    end
  end
end
