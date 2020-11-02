# frozen_string_literal: true

require 'rails/generators'

module Rails
  class ElasticMigrationGenerator < Rails::Generators::NamedBase
    def create_migration_file
      timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')

      template "migration.rb", "ee/lib/elastic/migrate/#{timestamp}_#{file_name}.rb"
    end

    def migration_class_name
      file_name.camelize
    end
  end
end
