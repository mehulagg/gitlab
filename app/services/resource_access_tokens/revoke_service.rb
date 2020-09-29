# frozen_string_literal: true

module ResourceAccessTokens
  class RevokeService < BaseService
    include Gitlab::Utils::StrongMemoize

    RevokeAccessTokenError = Class.new(RuntimeError)

    def initialize(current_user, resource, access_token)
      @current_user = current_user
      @access_token = access_token
      @bot_user = access_token.user
      @resource = resource
    end

    def execute
      return error("#{current_user.name} cannot delete #{bot_user.name}") unless can_destroy_bot_member?

      return error("Failed to find bot user") unless find_member

      PersonalAccessToken.transaction do
        access_token.revoke!

        raise RevokeAccessTokenError, "Failed to remove #{bot_user.name} member from: #{resource.name}" unless remove_member

        raise RevokeAccessTokenError, "Deletion of bot user failed" unless destroy_service
      end

      success("Revoked access token: #{access_token.name}")
    rescue ActiveRecord::ActiveRecordError, RevokeAccessTokenError => error
      log_error("Failed to revoke access token for #{bot_user.name}: #{error.message}")
      error(error.message)
    end

    private

    attr_reader :current_user, :access_token, :bot_user, :resource

    def remove_member
      ::Members::DestroyService.new(current_user).execute(find_member, destroy_bot: true)
    end

    def destroy_service
      ::Users::DestroyService.new(current_user).execute(bot_user, skip_authorization: true)
    end

    def can_destroy_bot_member?
      if resource.is_a?(Project)
        can?(current_user, :admin_project_member, @resource)
      elsif resource.is_a?(Group)
        can?(current_user, :admin_group_member, @resource)
      else
        false
      end
    end

    def find_member
      strong_memoize(:member) do
        if resource.is_a?(Project)
          resource.project_member(bot_user)
        elsif resource.is_a?(Group)
          resource.group_member(bot_user)
        else
          false
        end
      end
    end

    def error(message)
      ServiceResponse.error(message: message)
    end

    def success(message)
      ServiceResponse.success(message: message)
    end
  end
end
