# frozen_string_literal: true

module EE
  module API
    module Entities
      class EpicIssue < ::API::Entities::Issue
        expose :epic_issue_id
        expose :relative_position
      end
    end
  end
end
