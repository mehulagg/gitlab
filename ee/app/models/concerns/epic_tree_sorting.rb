# frozen_string_literal: true

module EpicTreeSorting
  extend ActiveSupport::Concern
  include FromUnion
  include RelativePositioning

  class_methods do
    def relative_positioning_query_base(object)
      from_union([
        EpicIssue.select("id, relative_position, epic_id as parent_id, epic_id, 'epic_issue' as object_type").in_epic(object.parent_ids),
        Epic.select("id, relative_position, parent_id, parent_id as epic_id, 'epic' as object_type").where(parent_id: object.parent_ids)
      ])
    end

    def relative_positioning_parent_column
      :epic_id
    end
  end

  included do
    extend ::Gitlab::Utils::Override

    override :update_relative_siblings
    def update_relative_siblings(relation, range, delta)
      items_to_update = relation
        .select(:id, :object_type)
        .where(relative_position: range)

      items_to_update.group_by { |item| item.object_type }.each do |type, group_items|
        ids = group_items.map(&:id)
        items = type.camelcase.constantize.where(id: ids).select(:id)
        items.update_all("relative_position = relative_position + #{delta}")
      end
    end

    override :exclude_self
    def exclude_self(relation, excluded: self)
      return relation unless excluded&.id.present?

      relation.where.not(*excluded.filter_epic_tree_node)
    end

    override :reset_relative_position
    def reset_relative_position
      current = scoped_items
        .where(*filter_epic_tree_node)
        .pluck(:relative_position)
        .first

      self.relative_position = current
    end

    def filter_epic_tree_node
      type = try(:object_type) || self.class.table_name.singularize

      ['object_type = ? AND id = ?', type, id]
    end
  end
end
