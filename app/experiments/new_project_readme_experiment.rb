# frozen_string_literal: true

class NewProjectReadmeExperiment < ApplicationExperiment
  def control_behavior
    false # we don't want the checkbox to be checked
  end

  def candidate_behavior
    true # check the checkbox by default
  end

  def track_first_write(project)
    return unless project.repository&.empty_repo?

    track(:write, property: project.created_at.to_s, value: 1)
  end
end
