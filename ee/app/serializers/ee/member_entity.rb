# frozen_string_literal: true

module EE
  module MemberEntity
    extend ActiveSupport::Concern

    prepended do
      expose :using_license do |member|
        can?(current_user, :owner_access, group) && member.user&.using_gitlab_com_seat?(group)
      end

      expose :group_sso do |member|
        member.user&.group_sso?(group)
      end

      expose :group_managed_account do |member|
        member.user&.group_managed_account?
      end

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
