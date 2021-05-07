# frozen_string_literal: true

module EE
  module TimeboxesRoutingHelper
    def iteration_path(iteration, *args)
      if iteration.group_timebox?
        group_iteration_path(iteration.group, iteration.id, *args)
      elsif iteration.project_timebox?
        project_iteration_path(iteration.project, iteration.id, *args)
      end
    end

    def iteration_url(iteration, *args)
      if iteration.group_timebox?
        group_iteration_url(iteration.group, iteration.id, *args)
      elsif iteration.project_timebox?
        project_iteration_url(iteration.project, iteration.id, *args)
      end
    end
  end
end
