# frozen_string_literal: true

module EE
  # Namespace EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `Namespace` model
  module Namespace
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Utils::StrongMemoize

    NAMESPACE_PLANS_TO_LICENSE_PLANS = {
      Plan::BRONZE        => License::STARTER_PLAN,
      Plan::SILVER        => License::PREMIUM_PLAN,
      Plan::GOLD          => License::ULTIMATE_PLAN,
      Plan::EARLY_ADOPTER => License::EARLY_ADOPTER_PLAN
    }.freeze

    LICENSE_PLANS_TO_NAMESPACE_PLANS = NAMESPACE_PLANS_TO_LICENSE_PLANS.invert.freeze
    PLANS = (NAMESPACE_PLANS_TO_LICENSE_PLANS.keys + [Plan::FREE]).freeze

    CI_USAGE_ALERT_LEVELS = [30, 5].freeze

    prepended do
      include EachBatch

      attr_writer :root_ancestor

      has_one :namespace_statistics
      has_one :gitlab_subscription, dependent: :destroy # rubocop:disable Cop/ActiveRecordDependent

      accepts_nested_attributes_for :gitlab_subscription

      scope :include_gitlab_subscription, -> { includes(:gitlab_subscription) }
      scope :join_gitlab_subscription, -> { joins("LEFT OUTER JOIN gitlab_subscriptions ON gitlab_subscriptions.namespace_id=namespaces.id") }
      scope :with_shared_runners_minutes_limit, -> { where("namespaces.shared_runners_minutes_limit > 0") }
      scope :with_extra_shared_runners_minutes_limit, -> { where("namespaces.extra_shared_runners_minutes_limit > 0") }
      scope :with_shared_runners_minutes_exceeding_default_limit, -> do
        where('namespace_statistics.namespace_id = namespaces.id')
        .where('namespace_statistics.shared_runners_seconds > (namespaces.shared_runners_minutes_limit * 60)')
      end

      scope :with_ci_minutes_notification_sent, -> do
        where('last_ci_minutes_notification_at IS NOT NULL OR last_ci_minutes_usage_notification_level IS NOT NULL')
      end

      scope :with_feature_available_in_plan, -> (feature) do
        plans = plans_with_feature(feature)
        matcher = Plan.where(name: plans)
          .joins(:hosted_subscriptions)
          .where("gitlab_subscriptions.namespace_id = namespaces.id")
          .select('1')
        where("EXISTS (?)", matcher)
      end

      delegate :shared_runners_minutes, :shared_runners_seconds, :shared_runners_seconds_last_reset,
        :extra_shared_runners_minutes, to: :namespace_statistics, allow_nil: true

      # Opportunistically clear the +file_template_project_id+ if invalid
      before_validation :clear_file_template_project_id

      validate :validate_shared_runner_minutes_support

      validates :max_pages_size,
                numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true,
                                less_than: ::Gitlab::Pages::MAX_SIZE / 1.megabyte }

      delegate :trial?, :trial_ends_on, :trial_starts_on, :upgradable?, to: :gitlab_subscription, allow_nil: true

      before_create :sync_membership_lock_with_parent

      # Changing the plan or other details may invalidate this cache
      before_save :clear_feature_available_cache
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      NamespaceStatisticsNotResetError = Class.new(StandardError)

      def plans_with_feature(feature)
        LICENSE_PLANS_TO_NAMESPACE_PLANS.values_at(*License.plans_with_feature(feature))
      end

      def reset_ci_minutes_in_batches!
        each_batch do |namespaces|
          namespace_ids = namespaces.pluck(:id)
          reset_ci_minutes!(namespace_ids)
        end
      end

      # ensure that recalculation of extra shared runners minutes occurs in the same
      # transaction as the reset of the namespace statistics. If the transaction fails
      # none of the changes apply but the numbers still remain consistent with each other.
      override :reset_ci_minutes!
      def reset_ci_minutes!(namespace_ids)
        transaction do
          recalculate_extra_shared_runners_minutes_limits!(namespace_ids)
          reset_shared_runners_seconds!(namespace_ids)
          reset_ci_minutes_notifications!(namespace_ids)
        end
        true
      rescue ActiveRecord::ActiveRecordError
        # We don't need to print thousands of namespace_ids
        # in the message if all batches failed.
        # A small batch would be sufficient for investigation.
        failed_namespace_ids = namespace_ids.first(10)

        raise EE::Namespace::NamespaceStatisticsNotResetError,
          "#{namespace_ids.count} namespace shared runner minutes were not reset and the transaction was rolled back. Namespace Ids: #{failed_namespace_ids}"
      end

      def extra_minutes_left_sql
        "GREATEST((namespaces.shared_runners_minutes_limit + namespaces.extra_shared_runners_minutes_limit) - ROUND(namespace_statistics.shared_runners_seconds / 60.0), 0)"
      end

      def recalculate_extra_shared_runners_minutes_limits!(namespace_ids)
        where(id: namespace_ids)
          .with_shared_runners_minutes_limit
          .with_extra_shared_runners_minutes_limit
          .with_shared_runners_minutes_exceeding_default_limit
          .update_all("extra_shared_runners_minutes_limit = #{extra_minutes_left_sql} FROM namespace_statistics")
      end

      def reset_shared_runners_seconds!(namespace_ids)
        NamespaceStatistics
          .where(namespace: namespace_ids)
          .where.not(shared_runners_seconds: 0)
          .update_all(shared_runners_seconds: 0, shared_runners_seconds_last_reset: Time.current)

        ::ProjectStatistics
          .where(namespace: namespace_ids)
          .where.not(shared_runners_seconds: 0)
          .update_all(shared_runners_seconds: 0, shared_runners_seconds_last_reset: Time.current)
      end

      def reset_ci_minutes_notifications!(namespace_ids)
        where(id: namespace_ids)
          .update_all(last_ci_minutes_notification_at: nil, last_ci_minutes_usage_notification_level: nil)
      end
    end

    override :move_dir
    def move_dir
      succeeded = super

      if succeeded
        all_projects.each do |project|
          ::Geo::RepositoryRenamedEventStore.new(
            project,
            old_path: project.path,
            old_path_with_namespace: old_path_with_namespace_for(project)
          ).create!
        end
      end

      succeeded
    end

    def old_path_with_namespace_for(project)
      project.full_path.sub(/\A#{Regexp.escape(full_path)}/, full_path_before_last_save)
    end

    # This makes the feature disabled by default, in contrary to how
    # `#feature_available?` makes a feature enabled by default.
    #
    # This allows to:
    # - Enable the feature flag for a given group, regardless of the license.
    #   This is useful for early testing a feature in production on a given group.
    # - Enable the feature flag globally and still check that the license allows
    #   it. This is the case when we're ready to enable a feature for anyone
    #   with the correct license.
    def beta_feature_available?(feature)
      ::Feature.enabled?(feature, self) ||
        (::Feature.enabled?(feature) && feature_available?(feature))
    end
    alias_method :alpha_feature_available?, :beta_feature_available?

    # Checks features (i.e. https://about.gitlab.com/pricing/) availabily
    # for a given Namespace plan. This method should consider ancestor groups
    # being licensed.
    override :feature_available?
    def feature_available?(feature)
      # This feature might not be behind a feature flag at all, so default to true
      return false unless ::Feature.enabled?(feature, default_enabled: true)

      available_features = strong_memoize(:feature_available) do
        Hash.new do |h, f|
          h[f] = load_feature_available(f)
        end
      end

      available_features[feature]
    end

    def feature_available_in_plan?(feature)
      return true if ::License.promo_feature_available?(feature)

      available_features = strong_memoize(:features_available_in_plan) do
        Hash.new do |h, f|
          h[f] = (plans.map(&:name) & self.class.plans_with_feature(f)).any?
        end
      end

      available_features[feature]
    end

    def actual_plan
      strong_memoize(:actual_plan) do
        if parent_id
          root_ancestor.actual_plan
        else
          subscription = find_or_create_subscription
          subscription&.hosted_plan || Plan.free || Plan.default
        end
      end
    end

    def actual_limits
      # We default to PlanLimits.new otherwise a lot of specs would fail
      # On production each plan should already have associated limits record
      # https://gitlab.com/gitlab-org/gitlab/issues/36037
      actual_plan&.limits || PlanLimits.new
    end

    def actual_plan_name
      actual_plan&.name || Plan::FREE
    end

    def plan_name_for_upgrading
      return Plan::FREE if trial_active?

      actual_plan_name
    end

    def actual_size_limit
      ::Gitlab::CurrentSettings.repository_size_limit
    end

    def sync_membership_lock_with_parent
      if parent&.membership_lock?
        self.membership_lock = true
      end
    end

    def shared_runner_minutes_supported?
      !has_parent?
    end

    def actual_shared_runners_minutes_limit(include_extra: true)
      extra_minutes = include_extra ? extra_shared_runners_minutes_limit.to_i : 0

      if shared_runners_minutes_limit
        shared_runners_minutes_limit + extra_minutes
      else
        ::Gitlab::CurrentSettings.shared_runners_minutes + extra_minutes
      end
    end

    def shared_runners_minutes_limit_enabled?
      shared_runner_minutes_supported? &&
        shared_runners_enabled? &&
        actual_shared_runners_minutes_limit.nonzero?
    end

    def shared_runners_minutes_used?
      shared_runners_minutes_limit_enabled? &&
        shared_runners_minutes.to_i >= actual_shared_runners_minutes_limit
    end

    def shared_runners_remaining_minutes_percent
      return 0 if shared_runners_remaining_minutes.to_f <= 0
      return 0 if actual_shared_runners_minutes_limit.to_f == 0

      (shared_runners_remaining_minutes.to_f * 100) / actual_shared_runners_minutes_limit.to_f
    end

    def shared_runners_remaining_minutes_below_threshold?
      shared_runners_remaining_minutes_percent.to_i <= last_ci_minutes_usage_notification_level.to_i
    end

    def extra_shared_runners_minutes_used?
      shared_runners_minutes_limit_enabled? &&
        extra_shared_runners_minutes_limit &&
        extra_shared_runners_minutes.to_i >= extra_shared_runners_minutes_limit
    end

    def shared_runners_enabled?
      all_projects.with_shared_runners.any?
    end

    def memoized_plans=(plans)
      @plans = plans # rubocop: disable Gitlab/ModuleWithInstanceVariables
    end

    def plans
      @plans ||=
        if parent_id
          Plan.hosted_plans_for_namespaces(self_and_ancestors.select(:id))
        else
          Plan.hosted_plans_for_namespaces(self)
        end
    end

    # When a purchasing a GL.com plan for a User namespace
    # we only charge for a single user.
    # This method is overwritten in Group where we made the calculation
    # for Group namespaces.
    def billable_members_count(_requested_hosted_plan = nil)
      1
    end

    # When a purchasing a GL.com plan for a User namespace
    # we only charge for a single user.
    # This method is overwritten in Group where we made the calculation
    # for Group namespaces.
    def billed_user_ids(_requested_hosted_plan = nil)
      [owner_id]
    end

    def eligible_for_trial?
      ::Gitlab.com? &&
        parent_id.nil? &&
        trial_ends_on.blank? &&
        [Plan::EARLY_ADOPTER, Plan::FREE].include?(actual_plan_name)
    end

    def trial_active?
      trial? && trial_ends_on.present? && trial_ends_on >= Date.today
    end

    def never_had_trial?
      trial_ends_on.nil?
    end

    def trial_expired?
      trial_ends_on.present? &&
        trial_ends_on < Date.today &&
        actual_plan_name == Plan::FREE
    end

    # A namespace may not have a file template project
    def checked_file_template_project
      nil
    end

    def checked_file_template_project_id
      checked_file_template_project&.id
    end

    def store_security_reports_available?
      feature_available?(:sast) ||
      feature_available?(:dependency_scanning) ||
      feature_available?(:container_scanning) ||
      feature_available?(:dast)
    end

    def free_plan?
      actual_plan_name == Plan::FREE
    end

    def early_adopter_plan?
      actual_plan_name == Plan::EARLY_ADOPTER
    end

    def bronze_plan?
      actual_plan_name == Plan::BRONZE
    end

    def silver_plan?
      actual_plan_name == Plan::SILVER
    end

    def gold_plan?
      actual_plan_name == Plan::GOLD
    end

    def use_elasticsearch?
      ::Gitlab::CurrentSettings.elasticsearch_indexes_namespace?(self)
    end

    private

    def validate_shared_runner_minutes_support
      return if shared_runner_minutes_supported?

      if shared_runners_minutes_limit_changed?
        errors.add(:shared_runners_minutes_limit, 'is not supported for this namespace')
      end
    end

    def clear_feature_available_cache
      clear_memoization(:feature_available)
    end

    def load_feature_available(feature)
      globally_available = License.feature_available?(feature)

      if ::Gitlab::CurrentSettings.should_check_namespace_plan?
        globally_available && feature_available_in_plan?(feature)
      else
        globally_available
      end
    end

    def clear_file_template_project_id
      return unless has_attribute?(:file_template_project_id)
      return if checked_file_template_project_id.present?

      self.file_template_project_id = nil
    end

    def find_or_create_subscription
      # Hosted subscriptions are only available for root groups for now.
      return if parent_id

      gitlab_subscription || generate_subscription
    end

    def generate_subscription
      return unless persisted?
      return if ::Gitlab::Database.read_only?

      create_gitlab_subscription(
        plan_code: Plan::FREE,
        trial: trial_active?,
        start_date: created_at,
        seats: 0
      )
    end

    def shared_runners_remaining_minutes
      [actual_shared_runners_minutes_limit.to_f - shared_runners_minutes.to_f, 0].max
    end
  end
end
