# frozen_string_literal: true

module Integrations
  module JiraSerializers
    class IssueSerializer < BaseSerializer
      include WithPagination

      entity ::Integrations::JiraSerializers::IssueEntity
    end
  end
end
