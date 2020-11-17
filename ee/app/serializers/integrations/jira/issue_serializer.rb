# frozen_string_literal: true

module Integrations
  module Jira
    class IssueSerializer < BaseSerializer
      include WithPagination

      entity ::Integrations::Jira::IssueEntity
    end
  end
end
