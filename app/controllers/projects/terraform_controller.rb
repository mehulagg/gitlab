# frozen_string_literal: true

class Projects::TerraformController < Projects::ApplicationController
  before_action :authenticate_user!
  before_action :authorize_can_read_terraform_state!

  def index
  end

  private

  def authorize_can_read_terraform_state!
    access_denied! unless can?(current_user, :read_terraform_state, project)
  end
end
