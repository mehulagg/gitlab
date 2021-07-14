# frozen_string_literal: true

module Registrations
  class GroupsProjectsController < ApplicationController

    layout 'minimal'

    before_action :check_if_gl_com_or_dev
    before_action :authorize_create_group!, only: :new

    feature_category :onboarding

    def new
      @group = Group.new(visibility_level: helpers.default_group_visibility)
    end

    def create
      @group = Groups::CreateService.new(current_user, group_params).execute

      if @group.persisted?
        experiment(:jobs_to_be_done, user: current_user)
          .track(:create_group, namespace: @group)
        create_successful_flow
      else
        render action: :new
      end
    end

    def create_successful_flow
      if helpers.in_trial_onboarding_flow?
        apply_trial_for_trial_onboarding_flow
      else
        registration_onboarding_flow
      end
    end

    protected

    def show_confirm_warning?
      false
    end

    private

    def group_params
      params.require(:group).permit(:name, :path, :visibility_level)
    end

    def authorize_create_group!
      access_denied! unless can?(current_user, :create_group)
    end
  end
end
