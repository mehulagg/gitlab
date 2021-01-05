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
        project_ids = updated_project_ids

        # Handle when group is moved from a group without advanced search enabled
        # to a group with advanced search enabled
        # We cannot know for sure whether the group was using Elasticsearch nor which type of limiting is configured,
        # so the ES cache is invalidated for the group and each associated project
        # otherwise, it is assumed all projects are indexed and only those with visibility changes are invalidated
        if ::Gitlab::CurrentSettings.elasticsearch_limit_indexing? && new_parent_group.use_elasticsearch?
          project_ids = group.all_projects.select(:id)

          ::Gitlab::CurrentSettings.invalidate_elasticsearch_indexes_cache_for_namespace!(group.id)
        end

        ::Project.id_in(project_ids).find_each do |project|
          ::Gitlab::CurrentSettings.invalidate_elasticsearch_indexes_cache_for_project!(project.id)

          project.maintain_elasticsearch_update(updated_attributes: [:visibility_level]) if project.maintaining_elasticsearch?
        end

        super
      end

      def lost_groups
        ancestors = group.ancestors

        if ancestors.include?(new_parent_group)
          group.ancestors_upto(new_parent_group)
        else
          ancestors
        end
      end
    end
  end
end
