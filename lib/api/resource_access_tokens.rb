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
        get ":id/access_tokens" do
          source = find_source(source_type, params[:id])
          bot_users = source.bots
      
          tokens = PersonalAccessTokensFinder.new({ user: bot_users, impersonation: false }.merge(state: 'active')).execute
         
          present paginate(tokens), with: Entities::PersonalAccessToken
        end
      end
    end
  end
end
