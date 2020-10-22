# frozen_string_literal: true

module API
  class Invitations < Grape::API::Instance
    before { authenticate! }

    helpers ::API::Helpers::MembersHelpers

    %w[group project].each do |source_type|
      params do
        requires :id, type: String, desc: "The #{source_type} ID"
      end
      resource source_type.pluralize, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do

        desc 'Invite non-members by email address to a group or project.' do
          success Entities::Invitation
        end
        params do
          requires :email, types: [String, Array[String]], desc: 'The email address to invite, or multiple emails separated by comma'
          requires :access_level, type: Integer, values: Gitlab::Access.all_values, desc: 'A valid access level (defaults: `30`, developer access level)'
          optional :expires_at, type: DateTime, desc: 'Date string in the format YEAR-MONTH-DAY'
        end
        # rubocop: disable CodeReuse/ActiveRecord
        post ":id/invitations", requirements: API::EMAIL_OR_EMAIL_LIST_REQUIREMENTS do
           source = find_source(source_type, params[:id])
           authorize_admin_source!(source_type, source)

          ::Members::InviteService.new(current_user, params).execute(source)
        end
        # rubocop: enable CodeReuse/ActiveRecord
      end
    end
  end
end

#API::Invitations.prepend_if_ee('EE::API::Invitations')
