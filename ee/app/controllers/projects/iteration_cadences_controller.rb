# frozen_string_literal: true

class Projects::IterationCadencesController < Projects::ApplicationController
  include IterationCadencesActions

  private

  def group
    project.group
  end
end
