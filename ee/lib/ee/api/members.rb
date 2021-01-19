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

            result = ::Members::UpdateService
              .new(current_user, { override: true })
              .execute(member, permission: :override)

            updated_member = result.fetch(:member, nil)

            if result[:status] == :success
              present_member(updated_member)
            else
              render_validation_error!(member)
            end
          end

          desc 'Remove an LDAP group member access level override.' do
            success Entities::Member
          end
          params do
            requires :user_id, type: Integer, desc: 'The user ID of the member'
          end
          delete ":id/members/:user_id/override" do
            member = find_member(params)

            result = ::Members::UpdateService
              .new(current_user, { override: false })
              .execute(member, permission: :override)

            updated_member = result.fetch(:member, nil)

            if result[:status] == :success
              present_member(updated_member)
            else
              render_validation_error!(member)
            end
          end

          desc 'Gets a list of billable users of root group.' do
            success Entities::Member
          end
          params do
            use :pagination
            optional :search, type: String, desc: 'The exact name of the subscribed member'
            optional :sort, type: String, desc: 'The sorting option', values: Helpers::MembersHelpers.member_sort_options
          end
          get ":id/billable_members" do
            group = find_group!(params[:id])

            bad_request!(nil) if group.subgroup?
            bad_request!(nil) unless ::Ability.allowed?(current_user, :admin_group_member, group)

            sorting = params[:sort] || 'id_asc'
            users = paginate(
              BilledUsersFinder.new(group,
                                    search_term: params[:search],
                                    order_by: sorting).execute
            )

            present users, with: ::EE::API::Entities::BillableMember, current_user: current_user
          end
        end
      end
    end
  end
end
