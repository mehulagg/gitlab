# frozen_string_literal: true

module Integrations
  module JiraSerializers
    class IssueDetailSerializer < BaseSerializer
      entity ::Integrations::JiraSerializers::IssueDetailEntity
    end
  end
end
