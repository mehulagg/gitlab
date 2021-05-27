# frozen_string_literal: true

# The connection between a source project (which defines the job token scope)
# and a target project which is the one allowed to be accessed by the job token.

module Ci
  module JobToken
    class ScopeLink < ApplicationRecord
      self.table_name = 'ci_job_token_scope_links'

      belongs_to :source_project, class_name: 'Project'
      belongs_to :target_project, class_name: 'Project'
      belongs_to :added_by, class_name: 'User'

      scope :from_project, ->(project) { where(source_project: project) }
      scope :to_project, ->(project) { where(target_project: project) }
    end
  end
end
