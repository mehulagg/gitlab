# frozen_string_literal: true

module Gitlab
  module Database
    module AsyncIndexes
      class IndexCreator
        include ExclusiveLeaseGuard

        TIMEOUT_PER_ACTION = 1.day

        attr_reader :async_index

        def initialize(async_index)
          @async_index = async_index
        end

        def perform
          try_obtain_lease do
            if index_exists?
              Gitlab::AppLogger.info "Skipping index creation since the index exists already: #{async_index}"
            else
              Gitlab::AppLogger.info "Creating async index: #{async_index}"
              connection.execute(async_index.definition)
            end

            async_index.destroy
          end
        end

        private

        def index_exists?
          connection.indexes(async_index.table_name).map(&:name).include?(async_index.name)
        end

        def connection
          @connection ||= ApplicationRecord.connection
        end

        def lease_timeout
          TIMEOUT_PER_ACTION
        end
      end
    end
  end
end
