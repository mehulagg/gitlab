# frozen_string_literal: true

module Gitlab
  module Restore
    class ExportTask
      # AvatarUpload object storage is broken in the server
      # Overriding it to avoid trying to export it
      class ::Group
        def avatar
          nil
        end
      end

      # We can't include Gitlab::ImportExport::CommandLineUtil because:
      # 1. it has a `execute` method
      # 2. it expects the class to have a `@shared` object
      module CommandLine
        include Gitlab::ImportExport::CommandLineUtil
        extend self

        def execute(cmd)
          output, status = Gitlab::Popen.popen(cmd)
          $logger.error(Gitlab::ImportExport::Error.new(output.to_s)) unless status == 0 # rubocop:disable Gitlab/ModuleWithInstanceVariables
          status == 0
        end
      end
      private_constant :CommandLine

      # Use the global logger to log to the same output
      # Log any errors
      module SharedExtension
        def error(exception)
          $logger.error(exception.message)

          super
        end

        Gitlab::ImportExport::Shared.prepend self
      end

      # When database is on readonly, do not try to write the ImportExportUpload record
      # Only compact the file to be moved to the right path
      class FileSaver < Gitlab::ImportExport::Saver
        # override
        def save
          compress_and_save
        end
      end

      class GroupsExportService < Groups::ImportExport::ExportService
        # Continue the group export even if one group fails
        class TreeSaver < Gitlab::ImportExport::Group::TreeSaver
          def save
            all_groups = Enumerator.new do |group_ids|
              groups.each do |group|
                begin
                  serialize(group)

                  group_ids << group.id
                rescue => e
                  $logger.error("Failed to serialize group #{group.path}: #{e.message}")
                end
              end
            end

            json_writer.write_relation_array('groups', '_all', all_groups)

            true
          rescue => e
            @shared.error(e)
            false
          ensure
            json_writer&.close
          end
        end

        # Continue the export even if one "saver" fails
        # Move the final file to the given path
        def execute(path)
          FileUtils.rm_rf(Dir["#{shared.base_path}/*"])

          savers.each do |saver|
            $logger.info ">>> Exporting #{saver.class.name}"
            saver.save
          rescue => e
            $logger.error "!!! Failed to save #{saver.class.name}: #{e.message}"
          end

          Dir["#{shared.archive_path}/*.tar.gz"].each do |file|
            FileUtils.mv(file, path)
          end
        ensure
          remove_base_tmp_dir
        end

        def file_saver
          FileSaver.new(exportable: @group, shared: @shared)
        end

        def tree_exporter_class
          TreeSaver
        end
      end

      # Ensure that the project exports will continue even if one of the "savers" fails.
      # "savers" - are the classes resposible for saving/exporting small portions of a project.
      class ProjectsExportService < Projects::ImportExport::ExportService
        # Remove repository.bundle if it fails to export
        class RepoSaver < Gitlab::ImportExport::RepoSaver
          # override
          def save
            unless super
              $logger.error("!!!! Failed to export repository for #{project.full_path}")
              FileUtils.rm_f(project_bundle)
            end

            true
          end

          private

          def project_bundle
            File.join(shared.export_path, 'project.bundle')
          end
        end

        # Move the final file to the given path
        def execute(path)
          save_all!

          FileSaver.new(exportable: project, shared: shared).save

          Dir["#{shared.archive_path}/*tar.gz"].each do |file|
            FileUtils.mv(file, path)
          end
        ensure
          cleanup
        end

        private

        # Continue the export even if an "exporter" fails
        def save_all!
          exporters.each do |exporter|
            $logger.info ">>>> Exporting #{exporter.class.name}"

            exporter.save
          rescue => e
            $logger.error "!!!! Failed to export #{exporter.class.name}: #{e.message}"
          end

          true
        end

        def repo_saver
          RepoSaver.new(project: project, shared: shared)
        end
      end

      def initialize(group_path:, username:, export_path:, logger:, page_size: 30, page: 0)
        @group = Group.find_by_full_path(group_path)
        raise ActiveRecord::RecordNotFound, "Group #{group_path} not found" unless @group

        @user = User.find_by!(username: username) # rubocop: disable CodeReuse/ActiveRecord

        @export_path = export_path
        @logger = logger
        $logger = logger
        @page_size = page_size
        @page = page
      end

      def execute
        CommandLine.mkdir_p(bundle_path)

        export_groups
        export_all_projects

        CommandLine.tar_czf(archive: bundle_filename, dir: bundle_path)

        logger.info("#{bundle_filename} export finished!")
      ensure
        FileUtils.rm_rf(bundle_path)
      end

      private

      attr_reader :group, :user, :export_path, :logger, :page, :page_size

      def export_groups
        logger.info(">> Exporting #{group.name} and all its subgroups")

        GroupsExportService
          .new(group: group, user: user)
          .execute(bundle_path)
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def export_all_projects
        all_projects = Project.where(group: group_tree).order_by(:id)

        all_projects.slice(page * page_size, page_size).each do |project|
          export_project(project)
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def export_project(project)
        target_path = if project.group.id == group.id
          # Root group projects does not use the namespace folder, as the group may have a different
          # path when importing
          bundle_path('projects')
        else
          bundle_path('projects', project.group.full_path_components[1..-1].join('/'))
        end

        CommandLine.mkdir_p(target_path) unless Dir.exist?(target_path)

        logger.info ">> Exporting project #{project.full_path}"

        ProjectsExportService
          .new(project, user)
          .execute(File.join(target_path, "#{project.path}.tar.gz"))
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def group_tree
        Gitlab::ObjectHierarchy
          .new(::Group.where(id: group.id))
          .base_and_descendants(with_depth: true)
          .order_by(:depth)
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def bundle_path(*path)
        File.join([export_path, 'bundle'].concat(path).compact)
      end

      def bundle_filename
        @filename ||= Gitlab::ImportExport.export_filename(exportable: group)

        File.join(export_path, @filename)
      end
    end
  end
end
