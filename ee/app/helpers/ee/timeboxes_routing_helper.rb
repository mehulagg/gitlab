# frozen_string_literal: true

module EE
  module TimeboxesRoutingHelper
    def iteration_path(iteration, *args)
      if iteration.group_timebox?
        group_iteration_path(iteration.group, iteration, *args)
      elsif iteration.project_timebox?
        # We don't have project iteration routes yet, so for now send users to the project itself
        project_path(iteration.project, *args)
      end
    end

    def iteration_url(iteration, *args)
      if iteration.group_timebox?
        group_iteration_url(iteration.group, iteration, *args)
      elsif iteration.project_timebox?
        # We don't have project iteration routes yet, so for now send users to the project itself
        project_url(iteration.project, *args)
      end
    end

    def inherited_iteration_path(project, iteration, *args)
      return unless iteration.group_timebox?

      project_iterations_inherited_path(project, iteration.id, *args)
    end

    def inherited_iteration_url(project, iteration, *args)
      return unless iteration.group_timebox?

      project_iterations_inherited_url(project, iteration.id, *args)
    end
  end
end
