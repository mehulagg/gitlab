# frozen_string_literal: true

module EE
  module ProjectMember
    extend ActiveSupport::Concern

    prepended do
      extend ::Gitlab::Utils::Override

      validate :sso_enforcement, if: :group
      validate :gma_enforcement, if: :group

      before_destroy :delete_member_branch_protection
    end

    def group
      source&.group
    end

    def delete_member_branch_protection
      if user.present? && project.present?
        project.protected_branches.merge_access_by_user(user).destroy_all # rubocop: disable Cop/DestroyAll
        project.protected_branches.push_access_by_user(user).destroy_all # rubocop: disable Cop/DestroyAll
      end
    end

    def gma_enforcement
      unless ::Gitlab::Auth::GroupSaml::GmaMembershipEnforcer.new(project).can_add_user?(user)
        errors.add(:user, _('is not in the group enforcing Group Managed Account'))
      end
    end
  end
end
