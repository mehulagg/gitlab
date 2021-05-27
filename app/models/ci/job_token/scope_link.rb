# frozen_string_literal: true

# TODO: add comment

module Ci
  module JobToken
    class ScopeLink < ApplicationRecord
      self.table_name = 'ci_job_token_scope_links'

      belongs_to :source_project, class_name: 'Project'
      belongs_to :target_project, class_name: 'Project'
      belongs_to :added_by, class_name: 'User'
    end
  end
end
