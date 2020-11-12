# frozen_string_literal: true
module EE
  module CurrentBoardEntity
    extend ActiveSupport::Concern

    prepended do
      expose :milestone_id
      expose :weight
      expose :label_ids
      expose :milestone, using: BoardMilestoneEntity
      expose :assignee, using: BoardAssigneeEntity
      expose :labels, using: BoardLabelEntity
      expose :hide_backlog_list
      expose :hide_closed_list
    end
  end
end
