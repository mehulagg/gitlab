# frozen_string_literal: true

module Registrations
  class GroupsController < ApplicationController
    include Registrations::GroupsControllerConcern

    layout 'minimal'

    feature_category :onboarding

    def new
      record_experiment_user(:learn_gitlab_a, learn_gitlab_context)
      record_experiment_user(:learn_gitlab_b, learn_gitlab_context)
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
  end
end
