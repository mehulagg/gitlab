# frozen_string_literal: true

module Gitlab
  module Database
    class SchemaVersionFiles
      SCHEMA_DIRECTORY = 'schema_migrations'
      MIGRATION_VERSION_GLOB = '20[0-9][0-9]*'

      def self.touch_all(database_name, versions_from_database, versions_from_migration_files)
        schema_directory = schema_directory_for(database_name)

        version_filepaths = find_version_filenames(schema_directory).map { |f| File.join(schema_directory, f) }
        FileUtils.rm(version_filepaths)

        versions_to_create = versions_from_database & versions_from_migration_files
        versions_to_create.each do |version|
          version_filepath = File.join(schema_directory, version)

          File.open(version_filepath, 'w') do |file|
            file << Digest::SHA256.hexdigest(version)
          end
        end
      end

      def self.load_all(database_name)
        schema_directory = schema_directory_for(database_name)
        version_filenames = find_version_filenames(schema_directory)
        return if version_filenames.empty?

        values = version_filenames.map { |vf| "('#{connection.quote_string(vf)}')" }
        connection.execute(<<~SQL)
          INSERT INTO schema_migrations (version)
          VALUES #{values.join(',')}
          ON CONFLICT DO NOTHING
        SQL
      end

      def self.db_dir
        @db_dir ||= Rails.application.config.paths["db"].first
      end

      def self.schema_directory_for(database_name)
        if ActiveRecord::Base.configurations.primary?(database_name)
          File.join(db_dir, SCHEMA_DIRECTORY)
        else
          File.join(db_dir, "#{database_name}_#{SCHEMA_DIRECTORY}")
        end
      end

      def self.find_version_filenames(schema_directory)
        Dir.glob(MIGRATION_VERSION_GLOB, base: schema_directory)
      end

      def self.connection
        ActiveRecord::Base.connection
      end
    end
  end
end
