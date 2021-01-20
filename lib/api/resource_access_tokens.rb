# frozen_string_literal: true

module API
  class ResourceAccessTokens < ::API::Base
    include PaginationParams

    before { authenticate! }

    feature_category :authentication_and_authorization

    helpers do
      def find_source(source_type, id)
        public_send("find_#{source_type}!", id) # rubocop:disable GitlabSecurity/PublicSend
      end

      def find_token(token_id)
        PersonalAccessToken.find(token_id) || not_found!
      end
    end

    %w[group project].each do |source_type|
      params do
        requires :id, type: String, desc: "The #{source_type} ID"
        optional :token_id, type: String, desc: "The ID of the token"
      end
      resource source_type.pluralize, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        get ":id/access_tokens" do
          resource = find_source(source_type, params[:id])
          bot_users = resource&.bots
          tokens = PersonalAccessTokensFinder.new({ user: bot_users, impersonation: false }.merge(state: 'active')).execute

          present paginate(tokens), with: Entities::PersonalAccessToken
        end

        delete ':id/access_tokens/:token_id' do
          resource = find_source(source_type, params[:id])
          token = find_token(params[:token_id])

          service = ::ResourceAccessTokens::RevokeService.new(
            current_user,
            resource,
            token
          ).execute

          service.success? ? no_content! : bad_request!(nil)
        end
      end
    end
  end
end
