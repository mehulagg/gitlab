# frozen_string_literal: true

module PersonalAccessTokens
  class CreateService < BaseService
    attr_reader :token, :target_user

    def initialize(current_user:, target_user:, params: {})
      @current_user = current_user
      @target_user = target_user
      @params = params.dup
      @ip_address = @params.delete(:ip_address)
    end

    def execute
      personal_access_token = target_user.personal_access_tokens.create(params.slice(*allowed_params))

      if personal_access_token.persisted?
        log_event(personal_access_token)
        ServiceResponse.success(payload: { personal_access_token: personal_access_token })
      else
        ServiceResponse.error(message: personal_access_token.errors.full_messages.to_sentence)
      end
    end

    private

    def allowed_params
      [
        :name,
        :impersonation,
        :scopes,
        :expires_at
      ]
    end

    def log_event(token)
      log_info(_("User %{current_user_username} has created personal access token with id %{pat_id} for user %{username}") %
        { current_user_username: current_user.username, pat_id: token.id, username: token.user.username })
    end
  end
end

PersonalAccessTokens::CreateService.prepend_if_ee('EE::PersonalAccessTokens::CreateService')
