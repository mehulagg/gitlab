# frozen_string_literal: true

class ProtectedBranch::PushAccessLevel < ApplicationRecord
  include ProtectedBranchAccess

  belongs_to :deploy_key

  protected_type = self.module_parent.model_name.singular
  validates :deploy_key,
            absence: true,
            unless: :protected_refs_for_users_required_and_available

  validates :access_level, uniqueness: { scope: protected_type, if: :role?,
            conditions: -> { where(deploy_key_id: nil) } }

  validates :deploy_key_id, uniqueness: { scope: protected_type, allow_nil: true }
  validate :validate_deploy_key_membership, if: :protected_refs_for_users_required_and_available

  def role?
    type == :role
  end

  def protected_refs_for_users_required_and_available
    type != :role && project.feature_available?(:protected_refs_for_users)
  end

  def validate_deploy_key_membership
    return unless deploy_key

    unless project.deploy_keys_projects.where(deploy_key_id: deploy_key.id).exists?
      self.errors.add(:deploy_key, 'is not enabled for this project')
    end
  end

  def type
    if self.deploy_key.present?
      :deploy_key
    else
      :role
    end
  end
end
