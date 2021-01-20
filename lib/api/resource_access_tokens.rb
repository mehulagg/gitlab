# frozen_string_literal: true

module API
  class ResourceAccessTokens < ::API::Base
    include PaginationParams

    before { authenticate! }

    feature_category :authentication_and_authorization

    helpers ::API::Helpers::MembersHelpers

    %w[group project].each do |source_type|
      params do
        requires :id, type: String, desc: "The #{source_type} ID"
      end
      resource source_type.pluralize, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        desc 'Gets a list of group or project members viewable by the authenticated user.' do
          success Entities::Member
        end
        params do
          optional :query, type: String, desc: 'A query string to search for members'
          optional :user_ids, type: Array[Integer], coerce_with: ::API::Validations::Types::CommaSeparatedToIntegerArray.coerce, desc: 'Array of user ids to look up for membership'
          optional :show_seat_info, type: Boolean, desc: 'Show seat information for members'
          use :optional_filter_params_ee
          use :pagination
        end

        get ":id/access_tokens" do
         # source = find_source(source_type, params[:id])
        #  PersonalAccessTokensFinder.new({ user: source.bots, impersonation: false}.merge(state: 'active')).execute
          source = Project.find(20)
          members = paginate(PersonalAccessTokensFinder.new({ user: source.bots, impersonation: false}.merge(state: 'active')).execute)

          present_members members
        end
      end
    end
  end
end

API::Members.prepend_if_ee('EE::API::Members')
