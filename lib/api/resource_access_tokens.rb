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
        desc 'Get list of all access tokens for the specified resource' do
          detail 'This feature was introduced in GitLab 13.9.'
        end
        get ":id/access_tokens" do
          resource = find_source(source_type, params[:id])
          bot_users = resource&.bots
          tokens = PersonalAccessTokensFinder.new({ user: bot_users, impersonation: false }.merge(state: 'active')).execute

          present paginate(tokens), with: Entities::PersonalAccessToken
        end

        desc 'Revokes a resource access token' do
          detail 'This feature was introduced in GitLab 13.9.'
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

        desc 'Create a resource access token' do
          detail 'This feature was introduced in GitLab 13.9.'
        end
        params do
          requires :name, type: String, desc: "Resource access token name"
          requires :scopes, type: Array[String], desc: "The permissions of the token"
          optional :expires_at, type: Date, desc: "The expiration date of the token"
        end
        post ':id/access_tokens' do
          resource = find_source(source_type, params[:id])

          token_response = ::ResourceAccessTokens::CreateService.new(
            current_user,
            resource,
            declared_params
          ).execute

          if token_response.success?
            present token_response.payload[:access_token], with: Entities::PersonalAccessToken
          else
            token_response.message
          end
        end
      end
    end
  end
end
