# frozen_string_literal: true

module Types
  class MilestoneSortEnum < SortEnum
    graphql_name 'MilestoneSort'
    description 'Values for sorting milestones'

    value 'DUE_DATE_ASC', 'Milestone due date by ascending order.', value: :due_date_asc
    value 'DUE_DATE_DESC', 'Milestone due date by descending order.', value: :due_date_desc
  end
end
