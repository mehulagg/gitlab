# frozen_string_literal: true

module Gitlab
  module Database
    module Reindexing
      # Maximum lease time for the global Redis lease
      # This should be higher than the maximum time for any
      # long running step in the reindexing process (compare with
      # statement timeouts).
      TIMEOUT_PER_ACTION = 1.day

      def self.perform(index_selector)
        Array.wrap(index_selector).each do |index|
          # This obtains a global lease such that there's
          # only one live reindexing process at a time.
          try_obtain_lease do
            ReindexAction.keep_track_of(index) do
              ConcurrentReindex.new(index).perform
            end
          end
        end
      end

      def self.try_obtain_lease
        lease = Gitlab::ExclusiveLease.new('gitlab_database_reindexing', timeout: TIMEOUT_PER_ACTION)

        unless lease.try_obtain
          Gitlab::AppLogger.warn(message: 'Cannot obtain an exclusive lease for database reindexing. Another instance must be running.')
          return
        end

        yield
      ensure
        lease.cancel if lease
      end
    end
  end
end
