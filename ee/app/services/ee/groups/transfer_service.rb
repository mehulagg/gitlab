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
        ::Project.id_in(updated_project_ids).find_each do |project|
          project.maintain_elasticsearch_update if project.maintaining_elasticsearch?
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
