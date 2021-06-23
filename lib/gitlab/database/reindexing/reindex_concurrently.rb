# frozen_string_literal: true

module Gitlab
  module Database
    module Reindexing
      class ReindexConcurrently
        include Gitlab::Utils::StrongMemoize

        ReindexError = Class.new(StandardError)

        TEMPORARY_INDEX_PATTERN = '\_ccnew[0-9]*'
        STATEMENT_TIMEOUT = 9.hours

        # When dropping an index, we acquire a SHARE UPDATE EXCLUSIVE lock,
        # which only conflicts with DDL and vacuum. We therefore execute this with a rather
        # high lock timeout and a long pause in between retries. This is an alternative to
        # setting a high statement timeout, which would lead to a long running query with effects
        # on e.g. vacuum.
        REMOVE_INDEX_RETRY_CONFIG = [[1.minute, 9.minutes]] * 30

        attr_reader :index, :logger

        def initialize(index, logger: Gitlab::AppLogger)
          @index = index
          @logger = logger
        end

        def perform
          raise ReindexError, 'indexes serving an exclusion constraint are currently not supported' if index.exclusion?
          raise ReindexError, 'index is a left-over temporary index from a previous reindexing run' if index.name =~ /#{TEMPORARY_INDEX_PATTERN}/

          # Expression indexes require additional statistics in `pg_statistic`:
          # select * from pg_statistic where starelid = (select oid from pg_class where relname = 'some_index');
          #
          # In PG12, this has been fixed in https://gitlab.com/postgres/postgres/-/commit/b17ff07aa3eb142d2cde2ea00e4a4e8f63686f96
          # following a GitLab.com incident that surfaced this (https://gitlab.com/gitlab-com/gl-infra/production/-/issues/2885).
          #
          # While this has been backpatched, we continue to disable expression indexes until further review.
          raise ReindexError, 'expression indexes are currently not supported' if index.expression?

          logger.info "Starting reindex of #{index}"

          set_statement_timeout do
            execute("REINDEX INDEX CONCURRENTLY #{quote_table_name(index.schema)}.#{quote_table_name(index.name)}")
          end
        ensure
          cleanup_dangling_indexes
        end

        private

        def cleanup_dangling_indexes
          Gitlab::Database::PostgresIndex.match("#{Regexp.escape(index.name)}#{TEMPORARY_INDEX_PATTERN}").each do |lingering_index|
            remove_index(lingering_index)
          end
        end

        def remove_index(index)
          logger.info("Removing dangling index #{index.identifier}")

          retries = Gitlab::Database::WithLockRetriesOutsideTransaction.new(
            timing_configuration: REMOVE_INDEX_RETRY_CONFIG,
            klass: self.class,
            logger: logger
          )

          retries.run(raise_on_exhaustion: false) do
            execute("DROP INDEX CONCURRENTLY IF EXISTS #{quote_table_name(index.schema)}.#{quote_table_name(index.name)}")
          end
        end

        def with_lock_retries(&block)
          arguments = { klass: self.class, logger: logger }
          Gitlab::Database::WithLockRetries.new(**arguments).run(raise_on_exhaustion: true, &block)
        end

        def set_statement_timeout
          execute("SET statement_timeout TO '%ds'" % STATEMENT_TIMEOUT)
          yield
        ensure
          execute('RESET statement_timeout')
        end

        delegate :execute, :quote_table_name, to: :connection
        def connection
          @connection ||= ActiveRecord::Base.connection
        end
      end
    end
  end
end
