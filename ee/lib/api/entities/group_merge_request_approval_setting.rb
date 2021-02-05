# frozen_string_literal: true

module API
  module Entities
    class GroupMergeRequestApprovalSetting < Grape::Entity
      expose :allow_author_approval
    end
  end
end
