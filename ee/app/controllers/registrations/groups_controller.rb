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

      render_new && return unless @group.persisted?

      trial = params[:trial] == 'true'
      url_params = { namespace_id: @group.id, trial: trial }

      if helpers.in_trial_onboarding_flow?
        render_new && return unless apply_trial

        url_params[:trial_onboarding_flow] = true
      else
        record_experiment_user(:trial_during_signup, trial_chosen: trial)

        if experiment_enabled?(:trial_during_signup)
          if trial
            render_new && return unless create_lead && apply_trial

            record_experiment_conversion_event(:trial_during_signup)
          end
        else
          invite_members(@group)
        end
      end

      redirect_to new_users_sign_up_project_path(url_params)
    end

    protected

    def show_confirm_warning?
      false
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

    def render_new
      render action: :new
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
          skip_email_confirmation: true,
          gitlab_com_trial: true,
          provider: 'gitlab',
          newsletter_segment: current_user.email_opted_in
        )
      }
      result = GitlabSubscriptions::CreateLeadService.new.execute(trial_params)
      flash[:alert] = result&.dig(:errors) unless result&.dig(:success)

      result&.dig(:success)
    end

    def apply_trial
      apply_trial_params = {
        uid: current_user.id,
        trial_user: params.permit(:glm_source, :glm_content).merge({
          namespace_id: @group.id,
          gitlab_com_trial: true,
          sync_to_gl: true
        })
      }

      result = GitlabSubscriptions::ApplyTrialService.new.execute(apply_trial_params)
      flash[:alert] = result&.dig(:errors) unless result&.dig(:success)

      result&.dig(:success)
    end
  end
end
