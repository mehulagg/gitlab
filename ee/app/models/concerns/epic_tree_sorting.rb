# frozen_string_literal: true

module EpicTreeSorting
  extend ActiveSupport::Concern
  include FromUnion
  include RelativePositioning

  class_methods do
    def relative_positioning_query_base(object)
      group_id = object.try(:group_id) || object.group.id
      epic_issue_type = EpicIssue.underscore
      epic_type = Epic.underscore

      issue_selection = <<~SELECT_LIST
        id, relative_position, epic_id as parent_id, epic_id,
        #{group_id}::int as group_id,
        '#{epic_issue_type}' as object_type
      SELECT_LIST
      epic_selection = <<~SELECT_LIST
        id, relative_position, parent_id, parent_id as epic_id,
        group_id,
        '#{epic_type}' as object_type
      SELECT_LIST

      from_union([
        EpicIssue.select(issue_selection).in_epic(object.parent_ids),
        Epic.select(epic_selection).in_parents(object.parent_ids).in_selected_groups(group_id)
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

      relation.where.not(*excluded.epic_tree_node_filter_condition)
    end

    override :reset_relative_position
    def reset_relative_position
      current = self.class.relative_positioning_query_base(self)
        .where(*epic_tree_node_filter_condition)
        .pluck(:relative_position)
        .first

      self.relative_position = current
    end

    def epic_tree_node_filter_condition
      ['object_type = ? AND id = ?', *epic_tree_node_identity]
    end

    def epic_tree_node_identity
      type = try(:object_type) || self.class.underscore

      [type, id]
    end
  end
end
