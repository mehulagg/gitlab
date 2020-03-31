# frozen_string_literal: true

class Plan < ApplicationRecord
  DEFAULT = 'default'.freeze
  FREE = 'free'.freeze
  BRONZE = 'bronze'.freeze
  SILVER = 'silver'.freeze
  GOLD = 'gold'.freeze
  EARLY_ADOPTER = 'early_adopter'.freeze

  # This constant must keep ordered by tier.
  PAID_HOSTED_PLANS = [BRONZE, SILVER, GOLD].freeze
  DEFAULT_PLANS = [DEFAULT, FREE].freeze
  ALL_HOSTED_PLANS = (PAID_HOSTED_PLANS + [EARLY_ADOPTER]).freeze

  has_many :hosted_subscriptions, class_name: 'GitlabSubscription', foreign_key: 'hosted_plan_id'
  has_one :limits, class_name: 'PlanLimits'

  def self.default
    Gitlab::SafeRequestStore[:plan_default] ||= find_by(name: DEFAULT)
  end

  def self.free
    return unless Gitlab.com?

    Gitlab::SafeRequestStore[:plan_free] ||= find_by(name: FREE)
  end

  def self.hosted_plans_for_namespaces(namespaces)
    namespaces = Array(namespaces)

    Plan
      .joins(:hosted_subscriptions)
      .where(name: ALL_HOSTED_PLANS)
      .where(gitlab_subscriptions: { namespace_id: namespaces })
      .distinct
  end

  def default?
    DEFAULT_PLANS.include?(name)
  end

  def paid?
    !default?
  end
end
