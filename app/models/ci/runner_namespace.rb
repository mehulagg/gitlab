# frozen_string_literal: true

module Ci
  class RunnerNamespace < ApplicationRecord
    extend Gitlab::Ci::Model
    include Limitable

    self.limit_scope = :group_limit_scope

    belongs_to :runner, inverse_of: :runner_namespaces
    belongs_to :namespace, inverse_of: :runner_namespaces, class_name: '::Namespace'
    belongs_to :group, class_name: '::Group', foreign_key: :namespace_id

    validates :runner_id, uniqueness: { scope: :namespace_id }
    validate :group_runner_type

    def group_limit_scope
      return unless ::Feature.enabled?(:ci_runner_limits, group, default_enabled: :yaml)

      Limitable::Scope.new(
        'ci_registered_group_runners',
        -> { group.actual_limits },
        Ci::Runner.belonging_to_group(group.self_and_hierarchy, include_ancestors: true))
    end

    private

    def group_runner_type
      errors.add(:runner, 'is not a group runner') unless runner&.group_type?
    end
  end
end
