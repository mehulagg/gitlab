# frozen_string_literal: true

class Projects::RequirementsManagement::RequirementsController < Projects::ApplicationController
  before_action :authorize_read_requirement!

  def index
    respond_to do |format|
      format.html
    end
  end
end
