# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # The migration is used to cleanup orphaned lfs_objects_projects in order to
    # introduce valid foreign keys to this table
    class CleanupOrphanedLfsObjectsProjects
      def perform(start_id, end_id)
        cleanup_lfs_objects_projects_without_lfs_object(start_id, end_id)
        cleanup_lfs_objects_projects_without_project(start_id, end_id)
      end

      private

      def cleanup_lfs_objects_projects_without_lfs_object(start_id, end_id)
        lfs_objects_projects_without_lfs_object =
          LfsObjectsProject
            .left_outer_joins(:lfs_object)
            .where(id: (start_id..end_id), lfs_objects: { id: nil })

        project_ids = lfs_objects_projects_without_lfs_object.pluck(:project_id).uniq.compact

        lfs_objects_projects_without_lfs_object.delete_all

        Project.where(id: project_ids).pluck(:id).each do |project_id|
          ProjectCacheWorker.perform_async(project_id, [], [:lfs_objects_size])
        end
      end

      def cleanup_lfs_objects_projects_without_project(start_id, end_id)
        lfs_objects_projects_without_project =
          LfsObjectsProject
            .left_outer_joins(:project)
            .where(id: (start_id..end_id), projects: { id: nil })

        lfs_objects_projects_without_project.delete_all
      end
    end
  end
end
