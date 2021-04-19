# frozen_string_literal: true

module EE
  module MemberEntity
    extend ActiveSupport::Concern

    prepended do
      expose :using_license do |member|
        # here it is - the 'can' part
        # can?(current_user, :owner_access, group) && member.user&.using_gitlab_com_seat?(group)
        true
      end

      expose :group_sso?, as: :group_sso

      expose :group_managed_account?, as: :group_managed_account

      expose :can_override do |member|
        member.can_override?
      end

      expose :override, as: :is_overridden
    end

    private

    def current_user
      options[:current_user]
    end

    def group
      options[:group]
    end
  end
end
