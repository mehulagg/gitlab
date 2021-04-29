# frozen_string_literal: true

module EE
  module API
    module Entities
      class BillableMember < ::API::Entities::UserBasic
        expose :public_email, as: :email
        expose :last_activity_on
        expose :source do |user, options|
          group_relationship(user, options)
        end

        private

        def group_relationship(user, options)
          return :group_member if options[:group_member_user_ids].include? user.id
          return :project_member if options[:project_member_user_ids].include? user.id
          return :group_invite if options[:shared_group_user_ids].include? user.id
          return :project_invite if options[:shared_project_user_ids].include? user.id
          return :ldap if user.ldap_user?
        end
      end
    end
  end
end
