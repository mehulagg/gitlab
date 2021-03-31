# frozen_string_literal: true

module Gitlab
  module Checks
    class LfsIntegrity
      def initialize(project, newrev, time_left)
        @project = project
        @newrev = newrev
        @time_left = time_left
      end

      def objects_missing?
        return false unless @newrev && @project.lfs_enabled?

        lfs_changes = Gitlab::Git::LfsChanges.new(@project.repository, @newrev)

        # If the check happens for a change which is using a quarantine
        # environment for incoming objects, then we can avoid doing the
        # necessary graph walk to detect only new LFS pointers and instead scan
        # through all quarantined objects.
        git_env = ::Gitlab::Git::HookEnv.all(project.repository.gl_repository)
        if git_env['GIT_OBJECT_DIRECTORY_RELATIVE'].present?
          new_lfs_pointers = lfs_changes.object_directory_pointers(object_limit: ::Gitlab::Git::Repository::REV_LIST_COMMIT_LIMIT, dynamic_timeout: @time_left)
        else
          new_lfs_pointers = lfs_changes.new_pointers(object_limit: ::Gitlab::Git::Repository::REV_LIST_COMMIT_LIMIT, dynamic_timeout: @time_left)
        end

        return false unless new_lfs_pointers.present?

        existing_count = @project.lfs_objects
                                 .for_oids(new_lfs_pointers.map(&:lfs_oid))
                                 .count

        existing_count != new_lfs_pointers.count
      end
    end
  end
end
