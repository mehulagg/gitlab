# frozen_string_literal: true

module EE
  module Groups
    module TransferService
      extend ::Gitlab::Utils::Override

      def update_group_attributes
        ::Epic.nullify_lost_group_parents(group.self_and_descendants, lost_groups)

        super
      end

      private

      override :post_update_hooks
      def post_update_hooks(updated_project_ids)
        super

        update_elasticsearch_hooks(updated_project_ids)
      end

      def lost_groups
        ancestors = group.ancestors

        if ancestors.include?(new_parent_group)
          group.ancestors_upto(new_parent_group)
        else
          ancestors
        end
      end

      def update_elasticsearch_hooks(updated_project_ids)
        project_ids = updated_project_ids

        # Handle when group is moved to a new group. There is no way to know
        # whether the group was using Elasticsearch before the transfer, so the ES cache is invalidated
        # for each associated project. Otherwise, it is assumed all projects are indexed
        # and only those with visibility changes have their ES cache entry invalidated
        if ::Gitlab::CurrentSettings.elasticsearch_limit_indexing?
          project_ids = group.all_projects.select(:id)
        end

        ::Project.id_in(project_ids).find_each do |project|
          project.invalidate_elasticsearch_indexes_cache!

          project.maintain_elasticsearch_update(updated_attributes: [:visibility_level]) if project.maintaining_elasticsearch?
        end
      end
    end
  end
end
