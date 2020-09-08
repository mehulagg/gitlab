# frozen_string_literal: true

class NamespaceSetting < ApplicationRecord
  belongs_to :namespace, inverse_of: :namespace_settings

  self.primary_key = :namespace_id

  validate :allow_mfa_for_group, on: :update, if: :allow_mfa_for_subgroups_changed?

  def allow_mfa_for_group
    if namespace&.parent_id
      errors.add(:allow_mfa_for_subgroups, "allow MFA setting is not allowed since group is not top-level group.")
    end
  end
end

NamespaceSetting.prepend_if_ee('EE::NamespaceSetting')
