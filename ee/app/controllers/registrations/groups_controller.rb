# frozen_string_literal: true

module Registrations
  class GroupsController < ApplicationController
    include GroupInviteMembers

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
        url_params = { namespace_id: @group.id }
        if trial_onboarding_flow?
          apply_trial
          url_params[:trial_flow] = params[:trial_flow]
        else
          invite_members(@group)
        end

        redirect_to new_users_sign_up_project_path(url_params)
      else
        render action: :new
      end
    end

    private

    def trial_onboarding_flow?
      params[:trial_flow] == 'true' && experiment_enabled?(:trial_onboarding_issues)
    end

    def authorize_create_group!
      access_denied! unless can?(current_user, :create_group)
    end

    def check_experiment_enabled
      access_denied! unless experiment_enabled?(:onboarding_issues)
    end

    def group_params
      params.require(:group).permit(:name, :path, :visibility_level)
    end

    def apply_trial
      apply_trial_params = {
        uid: current_user.id,
        trial_user: {
          namespace_id: @group.id,
          gitlab_com_trial: true,
          sync_to_gl: true
        }
      }

      result = GitlabSubscriptions::ApplyTrialService.new.execute(apply_trial_params)
      result&.dig(:success)
    end
  end
end
