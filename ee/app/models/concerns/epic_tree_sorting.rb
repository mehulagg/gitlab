# frozen_string_literal: true

module EpicTreeSorting
  extend ActiveSupport::Concern
  include FromUnion
  include RelativePositioning

  class_methods do
    extend ::Gitlab::Utils::Override

    def relative_positioning_query_base(object)
      # Only non-root nodes are sortable.
      return none if object.root_epic_tree_node?

      issue_type = EpicIssue.underscore
      epic_type = Epic.underscore

      issue_selection = <<~SELECT_LIST
        id, relative_position, epic_id as parent_id, epic_id, '#{issue_type}' as object_type
      SELECT_LIST
      epic_selection = <<~SELECT_LIST
        id, relative_position, parent_id, parent_id as epic_id, '#{epic_type}' as object_type
      SELECT_LIST

      from_union([
        EpicIssue.select(issue_selection).in_epic(object.parent_ids),
        Epic.select(epic_selection).in_parents(object.parent_ids)
      ])
    end

    def relative_positioning_parent_column
      :epic_id
    end

    override :move_nulls
    def move_nulls(objects, **args)
      super(objects&.reject(&:root_epic_tree_node?), **args)
    end
  end

  included do
    extend ::Gitlab::Utils::Override

    override :move_between
    def move_between(*)
      super unless root_epic_tree_node?
    end

    override :move_after
    def move_after(*)
      super unless root_epic_tree_node?
    end

    override :move_before
    def move_before(*)
      super unless root_epic_tree_node?
    end

    override :move_to_end
    def move_to_end
      super unless root_epic_tree_node?
    end

    override :move_to_start
    def move_to_start
      super unless root_epic_tree_node?
    end

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
