# frozen_string_literal: true
module EE
  module CurrentBoardEntity
    extend ActiveSupport::Concern

    prepended do
      expose :milestone_id
      expose :iteration_id
      expose :weight
      expose :label_ids
      expose :milestone, using: BoardMilestoneEntity
      expose :assignee, using: BoardAssigneeEntity
      expose :labels, using: BoardLabelEntity
    end
  end
end
