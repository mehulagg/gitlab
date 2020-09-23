# frozen_string_literal: true

module EE
  module API
    module Entities
      class EpicIssueLink < Grape::Entity
        expose :id
        expose :relative_position
        expose :epic do |epic_issue_link, _options|
          ::EE::API::Entities::Epic.represent(epic_issue_link.epic, with_reference: true)
        end
        expose :issue, using: ::API::Entities::IssueBasic
      end
    end
  end
end
