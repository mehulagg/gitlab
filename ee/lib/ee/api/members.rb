# frozen_string_literal: true

module EE
  module API
    module Members
      extend ActiveSupport::Concern

      prepended do
        params do
          requires :id, type: String, desc: 'The ID of a group'
        end
        resource :groups, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
          desc 'Overrides the access level of an LDAP group member.' do
            success Entities::Member
          end
          params do
            requires :user_id, type: Integer, desc: 'The user ID of the member'
          end
          post ":id/members/:user_id/override" do
            member = find_member(params)

            updated_member = ::Members::UpdateService
              .new(current_user, { override: true })
              .execute(member, permission: :override)

            present_member(updated_member)
          end

          desc 'Remove an LDAP group member access level override.' do
            success Entities::Member
          end
          params do
            requires :user_id, type: Integer, desc: 'The user ID of the member'
          end
          delete ":id/members/:user_id/override" do
            member = find_member(params)

            updated_member = ::Members::UpdateService
              .new(current_user, { override: false })
              .execute(member, permission: :override)

            present_member(updated_member)
          end
        end
      end
    end
  end
end
