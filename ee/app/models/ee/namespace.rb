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
      ::Plan::BRONZE        => License::STARTER_PLAN,
      ::Plan::SILVER        => License::PREMIUM_PLAN,
      ::Plan::GOLD          => License::ULTIMATE_PLAN
    }.freeze

    LICENSE_PLANS_TO_NAMESPACE_PLANS = NAMESPACE_PLANS_TO_LICENSE_PLANS.invert.freeze
    PLANS = (NAMESPACE_PLANS_TO_LICENSE_PLANS.keys + [Plan::FREE]).freeze
    TEMPORARY_STORAGE_INCREASE_DAYS = 30

    prepended do
      include EachBatch

      attr_writer :root_ancestor

      has_one :namespace_statistics
      has_one :namespace_limit, inverse_of: :namespace
      has_one :gitlab_subscription
      has_one :elasticsearch_indexed_namespace

      has_many :compliance_management_frameworks, class_name: "ComplianceManagement::Framework"

      accepts_nested_attributes_for :gitlab_subscription, update_only: true
      accepts_nested_attributes_for :namespace_limit

      scope :include_gitlab_subscription, -> { includes(:gitlab_subscription) }
      scope :include_gitlab_subscription_with_hosted_plan, -> { includes(gitlab_subscription: :hosted_plan) }
      scope :join_gitlab_subscription, -> { joins("LEFT OUTER JOIN gitlab_subscriptions ON gitlab_subscriptions.namespace_id=namespaces.id") }

      scope :top_most, -> { where(parent_id: nil) }

      scope :in_active_trial, -> do
        left_joins(gitlab_subscription: :hosted_plan)
          .where(gitlab_subscriptions: { trial: true, trial_ends_on: Date.today.. })
      end

      scope :in_default_plan, -> do
        left_joins(gitlab_subscription: :hosted_plan)
          .where(plans: { name: [nil, *::Plan.default_plans] })
      end

      scope :eligible_for_subscription, -> do
        top_most.in_active_trial.or(top_most.in_default_plan)
      end

      scope :eligible_for_trial, -> do
        left_joins(gitlab_subscription: :hosted_plan)
          .where(
            parent_id: nil,
            gitlab_subscriptions: { trial: [nil, false], trial_ends_on: [nil] },
            plans: { name: [nil, *::Plan::PLANS_ELIGIBLE_FOR_TRIAL] }
          )
      end

      scope :with_feature_available_in_plan, -> (feature) do
        plans = plans_with_feature(feature)
        matcher = ::Plan.where(name: plans)
          .joins(:hosted_subscriptions)
          .where("gitlab_subscriptions.namespace_id = namespaces.id")
          .select('1')
        where("EXISTS (?)", matcher)
      end

      delegate :shared_runners_seconds, :shared_runners_seconds_last_reset, to: :namespace_statistics, allow_nil: true

      delegate :additional_purchased_storage_size, :additional_purchased_storage_size=,
        :additional_purchased_storage_ends_on, :additional_purchased_storage_ends_on=,
        :temporary_storage_increase_ends_on, :temporary_storage_increase_ends_on=,
        :temporary_storage_increase_enabled?, :eligible_for_temporary_storage_increase?,
        to: :namespace_limit, allow_nil: true

      delegate :email, to: :owner, allow_nil: true, prefix: true

      # Opportunistically clear the +file_template_project_id+ if invalid
      before_validation :clear_file_template_project_id

      validate :validate_shared_runner_minutes_support

      validates :max_pages_size,
                numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true,
                                less_than: ::Gitlab::Pages::MAX_SIZE / 1.megabyte }

      delegate :trial?, :trial_ends_on, :trial_starts_on, :trial_days_remaining,
        :trial_percentage_complete, :upgradable?,
        to: :gitlab_subscription, allow_nil: true

      before_create :sync_membership_lock_with_parent

      # Changing the plan or other details may invalidate this cache
      before_save :clear_feature_available_cache
    end

    def namespace_limit
      super.presence || build_namespace_limit
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      def plans_with_feature(feature)
        LICENSE_PLANS_TO_NAMESPACE_PLANS.values_at(*License.plans_with_feature(feature))
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

    # Checks features (i.e. https://about.gitlab.com/pricing/) availabily
    # for a given Namespace plan. This method should consider ancestor groups
    # being licensed.
    override :feature_available?
    def feature_available?(feature)
      # This feature might not be behind a feature flag at all, so default to true
      return false unless ::Feature.enabled?(feature, type: :licensed, default_enabled: true)

      available_features = strong_memoize(:feature_available) do
        Hash.new do |h, f|
          h[f] = load_feature_available(f)
        end
      end

      available_features[feature]
    end

    def feature_available_in_plan?(feature)
      available_features = strong_memoize(:features_available_in_plan) do
        Hash.new do |h, f|
          h[f] = (plans.map(&:name) & self.class.plans_with_feature(f)).any?
        end
      end

      available_features[feature]
    end

    def feature_available_non_trial?(feature)
      feature_available?(feature.to_sym) && !trial_active?
    end

    override :actual_plan
    def actual_plan
      strong_memoize(:actual_plan) do
        if parent_id
          root_ancestor.actual_plan
        else
          subscription = find_or_create_subscription
          subscription&.hosted_plan
        end
      end || fallback_plan
    end

    def closest_gitlab_subscription
      strong_memoize(:closest_gitlab_subscription) do
        if parent_id
          root_ancestor.gitlab_subscription
        else
          gitlab_subscription
        end
      end
    end

    def plan_name_for_upgrading
      return ::Plan::FREE if trial_active?

      actual_plan_name
    end

    def over_storage_limit?
      ::Gitlab::CurrentSettings.enforce_namespace_storage_limit? &&
      ::Feature.enabled?(:namespace_storage_limit, root_ancestor) &&
        root_ancestor.root_storage_size.above_size_limit?
    end

    def total_repository_size_excess
      strong_memoize(:total_repository_size_excess) do
        namespace_size_limit = actual_size_limit
        namespace_limit_arel = Arel::Nodes::SqlLiteral.new(namespace_size_limit.to_s.presence || 'NULL')

        total_excess = total_repository_size_excess_calculation(::Project.arel_table[:repository_size_limit])
        total_excess += total_repository_size_excess_calculation(namespace_limit_arel, project_level: false) if namespace_size_limit.to_i > 0
        total_excess
      end
    end

    def repository_size_excess_project_count
      strong_memoize(:repository_size_excess_project_count) do
        namespace_size_limit = actual_size_limit

        count = projects_for_repository_size_excess.count
        count += projects_for_repository_size_excess(namespace_size_limit).count if namespace_size_limit.to_i > 0
        count
      end
    end

    def total_repository_size
      strong_memoize(:total_repository_size) do
        all_projects
          .joins(:statistics)
          .pluck(total_repository_size_arel.sum).first || 0 # rubocop:disable Rails/Pick
      end
    end

    def contains_locked_projects?
      total_repository_size_excess > additional_purchased_storage_size.megabytes
    end

    def actual_size_limit
      ::Gitlab::CurrentSettings.repository_size_limit
    end

    def sync_membership_lock_with_parent
      if parent&.membership_lock?
        self.membership_lock = true
      end
    end

    def ci_minutes_quota
      @ci_minutes_quota ||= ::Ci::Minutes::Quota.new(self)
    end

    # The same method name is used also at project and job level
    def shared_runners_minutes_limit_enabled?
      ci_minutes_quota.enabled?
    end

    def any_project_with_shared_runners_enabled?
      all_projects.with_shared_runners.any?
    end

    # These helper methods are required to not break the Namespace API.
    def memoized_plans=(plans)
      @plans = plans # rubocop: disable Gitlab/ModuleWithInstanceVariables
    end

    def plans
      @plans ||=
        if parent_id
          ::Plan.hosted_plans_for_namespaces(self_and_ancestors.select(:id))
        else
          ::Plan.hosted_plans_for_namespaces(self)
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
        !has_parent? &&
        never_had_trial? &&
        plan_eligible_for_trial?
    end

    def trial_active?
      trial? && trial_ends_on.present? && trial_ends_on >= Date.today
    end

    def never_had_trial?
      trial_ends_on.nil?
    end

    def trial_expired?
      trial_ends_on.present? && trial_ends_on < Date.today
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
      feature_available?(:secret_detection) ||
      feature_available?(:dependency_scanning) ||
      feature_available?(:container_scanning) ||
      feature_available?(:dast) ||
      feature_available?(:coverage_fuzzing) ||
      feature_available?(:api_fuzzing)
    end

    def free_plan?
      actual_plan_name == ::Plan::FREE
    end

    def bronze_plan?
      actual_plan_name == ::Plan::BRONZE
    end

    def silver_plan?
      actual_plan_name == ::Plan::SILVER
    end

    def gold_plan?
      actual_plan_name == ::Plan::GOLD
    end

    def plan_eligible_for_trial?
      ::Plan::PLANS_ELIGIBLE_FOR_TRIAL.include?(actual_plan_name)
    end

    def use_elasticsearch?
      ::Gitlab::CurrentSettings.elasticsearch_indexes_namespace?(self)
    end

    def enable_temporary_storage_increase!
      update(temporary_storage_increase_ends_on: TEMPORARY_STORAGE_INCREASE_DAYS.days.from_now)
    end

    def additional_repo_storage_by_namespace_enabled?
      !::Feature.enabled?(:namespace_storage_limit, self) &&
        ::Gitlab::CurrentSettings.automatic_purchased_storage_allocation?
    end

    def root_storage_size
      klass = additional_repo_storage_by_namespace_enabled? ? RootExcessStorageSize : RootStorageSize
      klass.new(self)
    end

    private

    def fallback_plan
      if ::Gitlab.com?
        ::Plan.free
      else
        ::Plan.default
      end
    end

    def validate_shared_runner_minutes_support
      return if root?

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

    def total_repository_size_excess_calculation(repository_size_limit, project_level: true)
      total_excess = (total_repository_size_arel - repository_size_limit).sum
      relation = projects_for_repository_size_excess((repository_size_limit unless project_level))
      relation.pluck(total_excess).first || 0 # rubocop:disable Rails/Pick
    end

    def total_repository_size_arel
      arel_table = ::ProjectStatistics.arel_table
      arel_table[:repository_size] + arel_table[:lfs_objects_size]
    end

    def projects_for_repository_size_excess(limit = nil)
      if limit
        all_projects
          .with_total_repository_size_greater_than(limit)
          .without_repository_size_limit
      else
        all_projects
          .with_total_repository_size_greater_than(::Project.arel_table[:repository_size_limit])
          .without_unlimited_repository_size_limit
      end
    end
  end
end
