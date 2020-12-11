# frozen_string_literal: true

module Registrations
  class GroupsController < ApplicationController
    include GroupInviteMembers

    layout 'checkout'

    before_action :authorize_create_group!, only: :new
    before_action :check_experiment_enabled

    feature_category :navigation

    def new
      record_experiment_user(:trial_during_signup)
      @group = Group.new(visibility_level: helpers.default_group_visibility)
    end

    def create
      @group = Groups::CreateService.new(current_user, group_params).execute
      trial = params[:trial] == 'true'

      if @group.persisted?
        record_experiment_user(:trial_during_signup, trial_chosen: trial)

        if experiment_enabled?(:trial_during_signup)
          if trial && create_lead && apply_trial
            record_experiment_conversion_event(:trial_during_signup)
          end
        else
          invite_members(@group)
        end

        redirect_to new_users_sign_up_project_path(namespace_id: @group.id, trial: trial)
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

    def group_params
      params.require(:group).permit(:name, :path, :visibility_level)
    end

    def create_lead
      trial_params = {
        trial_user: params.permit(
          :company_name,
          :company_size,
          :phone_number,
          :number_of_users,
          :country
        ).merge(
          work_email: current_user.email,
          first_name: current_user.first_name,
          last_name: current_user.last_name,
          uid: current_user.id,
          skip_email_confirmation:  true,
          gitlab_com_trial: true,
          provider: 'gitlab',
          newsletter_segment: current_user.email_opted_in
        )
      }
      result = GitlabSubscriptions::CreateLeadService.new.execute(trial_params)
      result[:success]
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
