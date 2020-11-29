# frozen_string_literal: true

module Elastic
  class DataMigrationService
    MIGRATIONS_PATH = 'ee/elastic/migrate'
    MIGRATION_REGEXP = /\A([0-9]+)_([_a-z0-9]*)\.rb\z/.freeze

    class << self
      def migration_files
        Dir[migrations_full_path]
      end

      def migrations
        migrations = migration_files.map do |file|
          version, name = parse_migration_filename(file)

          Elastic::MigrationRecord.new(version: version.to_i, name: name.camelize, filename: file)
        end

        migrations.sort_by(&:version)
      end

      def drop_migration_has_finished_cache!(migration)
        name = migration.name.underscore
        Rails.cache.delete cache_key(:migration_has_finished, name)
      end

      def migration_has_finished?(name)
        Rails.cache.fetch cache_key(:migration_has_finished, name), expires_in: 30.minutes do
          migration_has_finished_uncached?(name)
        end
      end

      def migration_has_finished_uncached?(name)
        migration = migrations.find { |migration| migration.name == name.to_s.camelize }

        !!migration&.load_from_index&.dig('_source', 'completed')
      end

      def mark_all_as_completed!
        migrations.each do |migration|
          migration.save!(completed: true)
          drop_migration_has_finished_cache!(migration)
        end
      end

      private

      def cache_key(method_name, *additional_key)
        [name, method_name, *additional_key]
      end

      def parse_migration_filename(filename)
        File.basename(filename).scan(MIGRATION_REGEXP).first
      end

      def migrations_full_path
        Rails.root.join(MIGRATIONS_PATH, '**', '[0-9]*_*.rb').to_s
      end
    end
  end
end
