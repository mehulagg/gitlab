# frozen_string_literal: true

class FeatureFlagScopeEntity < Grape::Entity
  include RequestAwareEntity

  expose :id
  expose :active
  expose :environment_scope
  expose :percentage
  expose :created_at
  expose :updated_at
end
