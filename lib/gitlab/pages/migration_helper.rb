# frozen_string_literal: true

module Gitlab
  module Pages
    class MigrationHelper
      def migrate_to_remote_storage(&block)
        deployments = ::PagesDeployment.with_files_stored_locally
        migrate(deployments, ObjectStorage::Store::REMOTE, &block)
      end

      def migrate_to_local_storage(&block)
        deployments = ::PagesDeployment.with_files_stored_remotely
        migrate(deployments, ObjectStorage::Store::LOCAL, &block)
      end

      private

      def batch_size
        ENV.fetch('MIGRATION_BATCH_SIZE', 10).to_i
      end

      def migrate(deployments, store, &block)
        deployments.find_each(batch_size: batch_size) do |deployment| # rubocop:disable CodeReuse/ActiveRecord
          deployment.file.migrate!(store)

          yield deployment if block
        rescue => e
          raise StandardError.new("Failed to transfer deployment of type #{deployment.file_type} and ID #{deployment.id} with error: #{e.message}")
        end
      end
    end
  end
end
