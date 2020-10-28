# frozen_string_literal: true

module ProtectedRefAccess
  extend ActiveSupport::Concern
  HUMAN_ACCESS_LEVELS = {
    Gitlab::Access::MAINTAINER => "Maintainers",
    Gitlab::Access::DEVELOPER => "Developers + Maintainers",
    Gitlab::Access::NO_ACCESS => "No one"
  }.freeze

  class_methods do
    def allowed_access_levels
      [
        Gitlab::Access::MAINTAINER,
        Gitlab::Access::DEVELOPER,
        Gitlab::Access::NO_ACCESS,
        Gitlab::Access::ADMIN
      ]
    end
  end

  included do
    belongs_to :user
    belongs_to :group

    scope :maintainer, -> { where(access_level: Gitlab::Access::MAINTAINER) }
    scope :developer, -> { where(access_level: Gitlab::Access::DEVELOPER) }
    scope :by_user, -> (user) { where(user_id: user ) }
    scope :by_group, -> (group) { where(group_id: group ) }
    scope :for_role, -> { where(user_id: nil, group_id: nil) }
    scope :for_user, -> { where.not(user_id: nil) }
    scope :for_group, -> { where.not(group_id: nil) }

    protected_type = self.module_parent.model_name.singular
    validates :group_id, uniqueness: { scope: protected_type, allow_nil: true }
    validates :user_id, uniqueness: { scope: protected_type, allow_nil: true }
    validates :access_level, uniqueness: { scope: protected_type, if: :role?,
                                            conditions: -> { where(user_id: nil, group_id: nil) } }
    validates :group, :user,
              absence: true,
              unless: :protected_refs_for_users_required_and_available

    validate :validate_group_membership, if: :protected_refs_for_users_required_and_available
    validate :validate_user_membership, if: :protected_refs_for_users_required_and_available
  end

  def humanize
    return self.user.name if self.user.present?
    return self.group.name if self.group.present?

    HUMAN_ACCESS_LEVELS[self.access_level]
  end

  def type
    if self.user.present?
      :user
    elsif self.group.present?
      :group
    else
      :role
    end
  end

  def role?
    type == :role
  end

  def check_access(user)
    return true if user.admin?
    return user.id == self.user_id if self.user.present?
    return group.users.exists?(user.id) if self.group.present?

    user.can?(:push_code, project) &&
      project.team.max_member_access(user.id) >= access_level
  end

  def protected_refs_for_users_required_and_available
    type != :role && project.feature_available?(:protected_refs_for_users)
  end

  # We don't need to validate the license if this access applies to a role.
  #
  # If it applies to a user/group we can only skip validation `nil`-validation
  # if the feature is available
  def validate_group_membership
    return unless group

    unless project.project_group_links.where(group: group).exists?
      self.errors.add(:group, 'does not have access to the project')
    end
  end

  def validate_user_membership
    return unless user

    unless project.team.member?(user)
      self.errors.add(:user, 'is not a member of the project')
    end
  end
end
