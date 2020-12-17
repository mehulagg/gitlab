# frozen_string_literal: true

module EE
  module API
    module Entities
      class GroupMergeRequestApprovalSettings < Grape::Entity
        expose :namespace_id
        expose :allow_author_approval
      end
    end
  end
end
