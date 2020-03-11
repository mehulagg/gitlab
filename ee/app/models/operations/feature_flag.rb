# frozen_string_literal: true

module Operations
  class FeatureFlag < ApplicationRecord
    include AtomicInternalId

    self.table_name = 'operations_feature_flags'

    belongs_to :project

    has_internal_id :iid, scope: :project, init: ->(s) { s&.project&.operations_feature_flags&.maximum(:iid) }, backfill: true, presence: false

    default_value_for :active, true

    # scopes exists only for the first version
    has_many :scopes, class_name: 'Operations::FeatureFlagScope'
    # strategies exists only for the second version
    has_many :strategies, class_name: 'Operations::FeatureFlags::Strategy'
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
    validate :version_associations

    before_create :build_default_scope, if: -> { legacy_flag? && scopes.none? }

    accepts_nested_attributes_for :scopes, allow_destroy: true
    accepts_nested_attributes_for :strategies

    scope :ordered, -> { order(:name) }

    scope :enabled, -> { where(active: true) }
    scope :disabled, -> { where(active: false) }

    enum version: {
      legacy_flag: 1,
      new_version_flag: 2
    }

    class << self
      def preload_relations
        preload(:scopes, strategies: :scopes)
      end

      def for_unleash_client(project, environment)
        includes(strategies: :scopes)
          .where(project: project)
          .merge(Operations::FeatureFlags::Scope.on_environment(environment))
          .reorder(:id)
          .references(:operations_scopes)
      end
    end

    private

    def version_associations
      if new_version_flag? && scopes.any?
        errors.add(:version_associations, 'version 2 feature flags may not have scopes')
      elsif legacy_flag? && strategies.any?
        errors.add(:version_associations, 'version 1 feature flags may not have strategies')
      end
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
  end
end
