# frozen_string_literal: true

module Registrations
  class GroupsController < ApplicationController
    layout 'checkout'

    before_action :authorize_create_group!, only: :new
    before_action :check_experiment_enabled

    feature_category :navigation

    def new
      @group = Group.new(visibility_level: helpers.default_group_visibility)
    end

    def create
      @group = Groups::CreateService.new(current_user, group_params).execute

      if @group.persisted?
        invite_teammates

        redirect_to new_users_sign_up_project_path(namespace_id: @group.id)
      else
        render action: :new
      end
    end

    private

    def authorize_create_group!
      access_denied! unless can?(current_user, :create_group)
    end

    def check_experiment_enabled
      access_denied! unless experiment_enabled?(:onboarding_issues)
    end

    def invite_teammates
      invite_params = {
        user_ids: emails_param[:emails].reject(&:blank?).join(','),
        access_level: Gitlab::Access::DEVELOPER
      }

      Members::CreateService.new(current_user, invite_params).execute(@group)
    end

    def group_params
      params.require(:group).permit(:name, :path, :visibility_level)
    end

    def emails_param
      params.require(:group).permit(emails: [])
    end
  end
end
