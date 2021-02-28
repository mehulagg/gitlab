# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This migration moves projects.container_registry_enabled values to
    # project_features.container_registry_access_level for the projects within
    # the given range of ids.
    class MoveContainerRegistryEnabledToProjectFeature
      MAX_BATCH_SIZE = 1_000

      module Migratable
        # Migration model namespace isolated from application code.
        class Project < ActiveRecord::Base
          self.table_name = 'projects'

          has_one :project_feature, inverse_of: :project
        end

        class ProjectFeature < ActiveRecord::Base
          self.table_name = 'project_features'

          ENABLED = 20
          DISABLED = 0

          belongs_to :project
        end
      end

      def perform(from_id, to_id)
        (from_id..to_id).each_slice(MAX_BATCH_SIZE) do |batch|
          process_batch(batch.first, batch.last)
        end
      end

      private

      def process_batch(from_id, to_id)
        update_projects_where_true(from_id, to_id)
        update_projects_where_false(from_id, to_id)
      end

      def update_projects_where_true(from_id, to_id)
        # Will it be better to do a join and update both tables in one query?
        ids = nil
        ActiveRecord::Base.transaction do
          # Use with_lock_retries here?
          res = ActiveRecord::Base.connection.execute(update_projects_sql_where_true(from_id, to_id))
          ids = res.collect { |a| a["id"] }

          # Is it possible for there to be projects with no corresponding project_features row?
          ProjectFeature.where(project_id: ids).update_all(container_registry_access_level: ProjectFeature::ENABLED)
        end

        logger.info(message: "#{self.class}: Moved container_registry_enabled true values for projects with ids #{ids}")
      end

      def update_projects_where_false(from_id, to_id)
        # project_features.container_registry_access_level defaults to 0 (DISABLED),
        # so no need to update project_features.container_registry_access_level
        # for projects where container_registry_enabled == false.
        ActiveRecord::Base.connection.execute(update_projects_sql_where_false(from_id, to_id))

        logger.info(message: "#{self.class}: Moved container_registry_enabled false values for projects with ids #{from_id}...#{to_id}")
      end

      def update_projects_sql_where_true(from_id, to_id)
        <<~SQL
        UPDATE projects
        SET container_registry_enabled = null
        WHERE id BETWEEN #{from_id} AND #{to_id} AND
        container_registry_enabled = true
        RETURNING id
        SQL
      end

      def update_projects_sql_where_false(from_id, to_id)
        <<~SQL
        UPDATE projects
        SET container_registry_enabled = null
        WHERE id BETWEEN #{from_id} AND #{to_id} AND
        container_registry_enabled = false
        SQL
      end

      def logger
        @logger ||= Gitlab::BackgroundMigration::Logger.build
      end
    end
  end
end
