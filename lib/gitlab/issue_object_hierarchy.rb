# frozen_string_literal: true

module Gitlab
  class IssueObjectHierarchy < ::Gitlab::ObjectHierarchy
    private

    def middle_table
      ::IssueLink.arel_table
    end

    def from_tables(cte)
      [objects_table, cte.table, middle_table]
    end

    def parent_id_column(_cte)
      middle_table[:source_id]
    end

    def ancestor_conditions(cte)
      middle_table[:source_id].eq(objects_table[:id]).and(
        middle_table[:target_id].eq(cte.table[:id])
      ).and(
        parent_link
      )
    end

    def descendant_conditions(cte)
      middle_table[:target_id].eq(objects_table[:id]).and(
        middle_table[:source_id].eq(cte.table[:id])
      ).and(
        parent_link
      )
    end

    def parent_link
      middle_table[:link_type].eq(IssueLink.link_types[IssueLink::TYPE_PARENT])
    end
  end
end
