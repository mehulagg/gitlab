# frozen_string_literal: true

class Projects::RequirementsManagement::RequirementsController < Projects::ApplicationController
  before_action :authorize_read_requirement!

  feature_category :requirements_management

  def index
    respond_to do |format|
      format.html
    end
  end
end
