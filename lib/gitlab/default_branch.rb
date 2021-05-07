# frozen_string_literal: true

# Class is used while we're migrating from master to main
module Gitlab
  class DefaultBranch
    def self.value(project: nil)
      Feature.enabled?(:main_branch_over_master, project, default_enabled: :yaml) ? 'main' : 'master'
    end
  end
end
