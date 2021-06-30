# frozen_string_literal: true

class Groups::IterationCadencesController < Groups::ApplicationController
  before_action :check_cadences_available!
  before_action :authorize_show_cadence!, only: [:index]

  feature_category :issue_tracking

  def index; end

  private

  def check_cadences_available!
    render_404 unless group.iteration_cadences_feature_flag_enabled?
  end

  def authorize_show_cadence!
    render_404 unless can?(current_user, :read_iteration_cadence, group)
  end
end
