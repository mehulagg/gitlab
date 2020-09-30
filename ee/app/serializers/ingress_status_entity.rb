# frozen_string_literal: true

class IngressStatusEntity < Grape::Entity
  include RequestAwareEntity

  expose :status, as: :status
  expose :has_legacy_app_label?, as: :has_legacy_app_label

  expose :instances, if: -> (rollout_status, _) { rollout_status.found? }
  expose :completion, if: -> (rollout_status, _) { rollout_status.found? }
  expose :complete?, as: :is_completed, if: -> (rollout_status, _) { rollout_status.found? }
end
