# frozen_string_literal: true

module Integrations
  module Jira
    class IssueDetailSerializer < BaseSerializer
      entity ::Integrations::Jira::IssueDetailEntity
    end
  end
end
