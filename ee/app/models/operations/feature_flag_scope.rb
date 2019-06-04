# frozen_string_literal: true

module Operations
  class FeatureFlagScope < ApplicationRecord
    prepend HasEnvironmentScope

    self.table_name = 'operations_feature_flag_scopes'

    belongs_to :feature_flag
    has_one :strategy, class_name: 'Operations::FeatureFlagStrategy', dependent: :destroy # rubocop:disable Cop/ActiveRecordDependent

    validates :environment_scope, uniqueness: {
      scope: :feature_flag,
      message: "(%{value}) has already been taken"
    }

    validates :environment_scope,
      if: :default_scope?, on: :update,
      inclusion: { in: %w(*), message: 'cannot be changed from default scope' }

    before_destroy :prevent_destroy_default_scope, if: :default_scope?

    accepts_nested_attributes_for :strategy

    scope :ordered, -> { order(:id) }
    scope :enabled, -> { where(active: true) }
    scope :disabled, -> { where(active: false) }

    def strategies
      if strategy && strategy.name == 'gradualRolloutUserId'
        [
          {
            name: 'gradualRolloutUserId',
            parameters: strategy.parameters
          }
        ]
      else
        [
          { name: 'default' }
        ]
      end
    end

    private

    def default_scope?
      environment_scope_was == '*'
    end

    def prevent_destroy_default_scope
      raise ActiveRecord::ReadOnlyRecord, "default scope cannot be destroyed"
    end
  end
end
