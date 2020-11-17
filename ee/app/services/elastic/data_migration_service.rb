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

      def migration_has_finished?(name)
        migration = migrations.find { |migration| migration.name == name.camelize }

        !!migration&.load_from_index&.dig('_source', 'completed')
      end

      def mark_all_as_completed!
        migrations.each { |migration| migration.save!(completed: true) }
      end

      private

      def parse_migration_filename(filename)
        File.basename(filename).scan(MIGRATION_REGEXP).first
      end

      def migrations_full_path
        Rails.root.join(MIGRATIONS_PATH, '**', '[0-9]*_*.rb').to_s
      end
    end
  end
end
