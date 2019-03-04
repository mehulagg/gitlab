# frozen_string_literal: true

module Operations
  ##
  # NOTE:
  # "operations_feature_flags.active" column is not used in favor of
  # operations_feature_flag_scopes's override policy.
  # You can calculate actual `active` values with `for_environment` method.
  class FeatureFlag < ActiveRecord::Base
    self.table_name = 'operations_feature_flags'

    belongs_to :project

    default_value_for :active, true

    attr_accessor :user

    has_many :scopes, class_name: 'Operations::FeatureFlagScope'
    has_one :default_scope, -> { where(environment_scope: '*') }, class_name: 'Operations::FeatureFlagScope'

    validates :project, presence: true
    validates :name,
      presence: true,
      length: 2..63,
      format: {
        with: Gitlab::Regex.feature_flag_regex,
        message: Gitlab::Regex.feature_flag_regex_message
      }
    validates :name, uniqueness: { scope: :project_id }
    validates :description, allow_blank: true, length: 0..255
    validate :first_default_scope, on: :create, if: :has_scopes?

    before_create :build_default_scope, unless: :has_scopes?
    after_create :audit_event_create
    before_update :audit_event_update
    after_update :update_default_scope
    before_destroy :audit_event_destroy

    AUDITABLE_ATTRIBUTES = %w[name description]

    accepts_nested_attributes_for :scopes, allow_destroy: true

    scope :ordered, -> { order(:name) }

    scope :enabled, -> do
      where('EXISTS (?)', join_enabled_scopes)
    end

    scope :disabled, -> do
      where('NOT EXISTS (?)', join_enabled_scopes)
    end

    scope :for_environment, -> (environment) do
      select("operations_feature_flags.*" \
             ", (#{actual_active_sql(environment)}) AS active")
    end

    scope :for_list, -> do
      select("operations_feature_flags.*" \
             ", COALESCE((#{join_enabled_scopes.to_sql}), FALSE) AS active")
    end

    class << self
      def actual_active_sql(environment)
        Operations::FeatureFlagScope
          .where('operations_feature_flag_scopes.feature_flag_id = ' \
                 'operations_feature_flags.id')
          .on_environment(environment, relevant_only: true)
          .select('active')
          .to_sql
      end

      def join_enabled_scopes
        Operations::FeatureFlagScope
          .where('operations_feature_flags.id = feature_flag_id')
          .enabled.limit(1).select('TRUE')
      end

      def preload_relations
        preload(:scopes)
      end
    end

    def strategies
      [
        { name: 'default' }
      ]
    end

    private

    def audit_event_create
      return true unless !auditable_changes.empty? && user

      message = "Created feature flag <strong>#{name}</strong> with description <strong>\"#{description}\"</strong>."

      ::AuditEventService.new(user, project, audit_event_base(message)).security_event
    end

    def audit_event_update
      return true unless !auditable_changes.empty? && user

      message = "Updated feature flag "
      auditable_changes.each do |attribute, change|
        message += "#{attribute} of feature flag from #{change.first} to #{change.second} "
      end

      ::AuditEventService.new(user, project, audit_event_base(message)).security_event
    end

    def audit_event_destroy
      return true unless user

      message = "Destroyed feature flag"

      ::AuditEventService.new(user, project, audit_event_base(message)).security_event
    end

    def auditable_changes
      @auditable_changes ||= changes.select { |attribute, _| AUDITABLE_ATTRIBUTES.include?(attribute) }
    end

    def audit_event_base(message)
      {
        custom_message: message,
        target_id: self.id,
        target_type: self.class.name,
        target_details: self.name
      }
    end

    def first_default_scope
      unless scopes.first.environment_scope == '*'
        errors.add(:default_scope, 'has to be the first element')
      end
    end

    def build_default_scope
      scopes.build(environment_scope: '*', active: self.active)
    end

    def has_scopes?
      scopes.any?
    end

    def update_default_scope
      default_scope.update(active: self.active) if self.active_changed?
    end
  end
end
