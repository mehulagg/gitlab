# frozen_string_literal: true

require_relative '../../migration_helpers'

module RuboCop
  module Cop
    module Migration
      # Cop that prevents the use of hash indexes in database migrations
      class RenameTable < RuboCop::Cop::Cop
        include MigrationHelpers

        RENAME_CONSTANT_NAME = :TABLES_TO_BE_RENAMED
        METHOD_NAME = 1
        FROM_TABLE = 2
        TO_TABLE = 3

        class MigrationFile
          attr_reader :path, :version

          def initialize(path, version)
            @path = path
            @version = version
          end

          def post_migration?
            path.include?('post_migrate')
          end
        end

        # Detects rename_table_safely and finalize_table_rename method calls. Stores the table names.
        class RenameMethodCallDetector < Parser::AST::Processor
          include RuboCop::AST::Traversal

          def initialize(migration_collector, migration_file)
            @migration_collector = migration_collector
            @migration_file = migration_file
          end

          def on_send(node)
            if node.children[METHOD_NAME] == :rename_table_safely
              raise "'rename_table_safely' cannot be called in a post migration (#{@migration.path})" if @migration.post_migration?

              parse_tables(node, :migration) unless @migration_file.post_migration?
            elsif node.children[METHOD_NAME] == :finalize_table_rename
              raise "'finalize_table_rename' cannot be called in a migration (#{@migration.path})" unless @migration.post_migration?

              parse_tables(node, :post_migration) if @migration_file.post_migration?
            end
          end

          private

          def parse_tables(node, migration_type)
            old_table_name = node.children[FROM_TABLE].children[0]
            new_table_name = node.children[TO_TABLE].children[0]

            key = { old_table_name => new_table_name }
            @migration_collector[key] ||= { migration: nil, post_migration: nil }
            @migration_collector[key][migration_type] = @migration_file
          end
        end

        class TableModificationDetector < Parser::AST::Processor
          include RuboCop::AST::Traversal

          def initialize(tables, migration_file, offenses)
            @tables = tables
            @migration_file = migration_file
            @offenses = offenses
          end

          def on_send(node)
            if any_reference_to_tables?(node)
              @offenses << [@migration_file, @tables]
            end
          end

          private

          def any_reference_to_tables?(node)
            node.children.any? do |child|
              child.respond_to?(:children) && child.children.any? { |c| @tables.any? { |table| table == c } }
            end
          end
        end

        def on_send(node)
          tables_to_be_renamed = {}
          node.each_ancestor do |ancestor|
            if ancestor.type == :casgn && ancestor.children[1] == RENAME_CONSTANT_NAME
              node.each_node(:pair) do |pair|
                old_table_name = pair.children[0].children[0]
                new_table_name = pair.children[1].children[0]

                tables_to_be_renamed.merge!(old_table_name => new_table_name)
              end
            end
          end

          return if tables_to_be_renamed.empty?

          renames = collect_migration_file_ranges(tables_to_be_renamed)

          renames.each do |tables, migrations|
            unless migrations[:migration]
              add_offense(node, location: :expression, message: "Migration is missing for the following table rename migration: #{tables.inspect}")

              break
            end

            unless migrations[:post_migration]
              add_offense(node, location: :expression, message: "Post migration is missing for the following table rename migration: #{tables.inspect}")

              break
            end

            version_start = migrations[:migration].version
            version_end = migrations[:post_migration].version
            start_index = migration_files.find_index { |migration| migration[:version].eql?(version_start) }
            end_index = migration_files.find_index { |migration| migration[:version].eql?(version_end) }

            offenses = []
            migration_files[(start_index + 1)...end_index].each do |migration|
              verify_migration_not_referencing_tables(migration, tables.to_a.flatten, offenses)
            end

            offenses.uniq.each do |offense|
              migration_file, *tables = offense
              message = offense_message(migration_file, tables, version_end)
              add_offense(node, location: :expression, message: message)
            end
          end
        end

        def offense_message(migration_file, tables, version_end)
          """
          Dangerous migration found!
          The following migration file (#{migration_file}) contains references to one of the tables (#{tables.join(', ')} that are going to be renamed. Running other migrations while the table rename process is ongoing is prohobited.

          To fix this, change the timestamp of the migration file higher than #{version_end}.
          """
        end

        def verify_migration_not_referencing_tables(migration, tables, offenses)
          source = RuboCop::ProcessedSource.new(File.read(migration.path), config.target_ruby_version)
          source.ast.each_node do |node|
            TableModificationDetector.new(tables, migration.path, offenses).process(node)
          end
        end

        def migration_files
          @migration_files ||= begin
            files = Dir['db/migrate/*.rb'].concat(Dir['db/post_migrate/*.rb'])

            files
              .map { |file| MigrationFile.new(file, file[%r{migrate/(\d+)_}, 1]) }
              .sort_by(&:version)
          end
        end

        def collect_migration_file_ranges(tables_to_be_renamed)
          {}.tap do |migration_file_ranges|
            migration_files.each do |migration_file|
              source = RuboCop::ProcessedSource.new(File.read(migration_file.path), config.target_ruby_version)
              source.ast.each_node { |node| RenameMethodCallDetector.new(migration_file_ranges, migration_file).process(node) }
            end
          end
        end
      end
    end
  end
end
