# frozen_string_literal: true

class Groups::CadencesController < Groups::ApplicationController
  before_action :check_cadences_available!
  before_action :authorize_show_cadence!, only: [:index, :show]
  before_action :authorize_create_cadence!, only: [:new]

  feature_category :issue_tracking

  def new; end

  private

  def check_cadences_available!
    render_404 unless group.iteration_cadences_feature_flag_enabled?
  end

  def authorize_create_cadence!
    render_404 unless can?(current_user, :create_iteration, group)
  end

  def authorize_show_cadence!
    render_404 unless can?(current_user, :create_iteration, group)
  end
end
