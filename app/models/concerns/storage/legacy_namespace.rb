module Storage
  module LegacyNamespace
    extend ActiveSupport::Concern

    def move_dir
      if any_project_has_container_registry_tags?
        raise Gitlab::UpdatePathError.new('Namespace cannot be moved, because at least one project has tags in container registry')
      end

      parent_was = if parent_changed? && parent_id_was.present?
                     Namespace.find(parent_id_was) # raise NotFound early if needed
                   end

      move_repositories

      if parent_changed?
        former_parent_full_path = parent_was&.full_path
        parent_full_path = parent&.full_path
        Gitlab::UploadsTransfer.new.move_namespace(path, former_parent_full_path, parent_full_path)
        Gitlab::PagesTransfer.new.move_namespace(path, former_parent_full_path, parent_full_path)
      else
        Gitlab::UploadsTransfer.new.rename_namespace(full_path_was, full_path)
        Gitlab::PagesTransfer.new.rename_namespace(full_path_was, full_path)
      end

      remove_exports!

      # If repositories moved successfully we need to
      # send update instructions to users.
      # However we cannot allow rollback since we moved namespace dir
      # So we basically we mute exceptions in next actions
      begin
        send_update_instructions
        write_projects_repository_config
      rescue => e
        # Raise if development/test environment, else just notify Sentry
        Gitlab::Sentry.track_exception(e, extra: { full_path_was: full_path_was, full_path: full_path, action: 'move_dir' })
      end

      true # false would cancel later callbacks but not rollback
    end

    # Hooks

    # Save the storages before the projects are destroyed to use them on after destroy
    def prepare_for_destroy
      old_repository_storages
    end

    private

    def move_repositories
      # Move the namespace directory in all storages used by member projects
      repository_storages.each do |repository_storage|
        # Ensure old directory exists before moving it
        gitlab_shell.add_namespace(repository_storage, full_path_was)

        # Ensure new directory exists before moving it (if there's a parent)
        gitlab_shell.add_namespace(repository_storage, parent.full_path) if parent

        unless gitlab_shell.mv_namespace(repository_storage, full_path_was, full_path)

          Rails.logger.error "Exception moving path #{repository_storage} from #{full_path_was} to #{full_path}"

          # if we cannot move namespace directory we should rollback
          # db changes in order to prevent out of sync between db and fs
          raise Gitlab::UpdatePathError.new('namespace directory cannot be moved')
        end
      end
    end

    def old_repository_storages
      @old_repository_storage_paths ||= repository_storages
    end

    def repository_storages
      # We need to get the storage paths for all the projects, even the ones that are
      # pending delete. Unscoping also get rids of the default order, which causes
      # problems with SELECT DISTINCT.
      Project.unscoped do
        all_projects.select('distinct(repository_storage)').to_a.map(&:repository_storage)
      end
    end

    def rm_dir
      # Remove the namespace directory in all storages paths used by member projects
      old_repository_storages.each do |repository_storage|
        # Move namespace directory into trash.
        # We will remove it later async
        new_path = "#{full_path}+#{id}+deleted"

        if gitlab_shell.mv_namespace(repository_storage, full_path, new_path)
          Gitlab::AppLogger.info %Q(Namespace directory "#{full_path}" moved to "#{new_path}")

          # Remove namespace directroy async with delay so
          # GitLab has time to remove all projects first
          run_after_commit do
            GitlabShellWorker.perform_in(5.minutes, :rm_namespace, repository_storage, new_path)
          end
        end
      end

      remove_exports!
    end

    def remove_legacy_exports!
      legacy_export_path = File.join(Gitlab::ImportExport.storage_path, full_path_was)

      FileUtils.rm_rf(legacy_export_path)
    end
  end
end
