# frozen_string_literal: true

module Limitable
  extend ActiveSupport::Concern
  GLOBAL_SCOPE = :limitable_global_scope

  included do
    class_attribute :limit_scope
    class_attribute :limit_name
    self.limit_name = self.name.demodulize.tableize

    validate :validate_plan_limit_not_exceeded, on: :create
  end

  class Scope
    attr_reader :name, :actual_limits, :relation

    def initialize(name, actual_limits, relation)
      @name = name
      @actual_limits = actual_limits
      @relation = relation
    end
  end

  def instance_limit_name
    scope&.name
  end

  private

  def validate_plan_limit_not_exceeded
    if GLOBAL_SCOPE == limit_scope
      validate_global_plan_limit_not_exceeded
    else
      validate_scoped_plan_limit_not_exceeded
    end
  end

  def default_limitable_scope(scope_relation)
    Scope.new(limit_name, scope_relation.actual_limits, self.class.where(limit_scope => scope_relation))
  end

  def scope
    scope_relation = self.public_send(limit_scope) # rubocop:disable GitlabSecurity/PublicSend
    return unless scope_relation

    scope_relation.is_a?(Scope) ? scope_relation : default_limitable_scope(scope_relation)
  end

  def validate_scoped_plan_limit_not_exceeded
    actual_scope = scope
    return unless actual_scope

    check_plan_limit_not_exceeded(actual_scope)
  end

  def validate_global_plan_limit_not_exceeded
    scope = Scope.new(limit_name, Plan.default.actual_limits, self.class.all)

    check_plan_limit_not_exceeded(scope)
  end

  def check_plan_limit_not_exceeded(scope)
    actual_limits = scope.actual_limits
    actual_limits = actual_limits.call if actual_limits.is_a?(Proc)

    return unless actual_limits.exceeded?(scope.name, scope.relation)

    errors.add(:base, _("Maximum number of %{name} (%{count}) exceeded") %
        { name: scope.name.humanize(capitalize: false), count: actual_limits.public_send(scope.name) }) # rubocop:disable GitlabSecurity/PublicSend
  end
end
