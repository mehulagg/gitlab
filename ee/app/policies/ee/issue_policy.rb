# frozen_string_literal: true

module EE
  module IssuePolicy
    extend ActiveSupport::Concern

    prepended do
      condition(:over_storage_limit, scope: :subject) { @subject.namespace.over_storage_limit? }

      rule { over_storage_limit }.policy do
        prevent :create_issue
        prevent :update_issue
        prevent :read_issue_iid
        prevent :reopen_issue
        prevent :create_design
        prevent :create_note
      end
    end
  end
end
