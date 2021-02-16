# frozen_string_literal: true

# WARNING: This finder does not check permissions!
#
# Arguments:
#   params:
#     group: Group model - Find deployments within a group (including subgroups)
#
# Note: If project and group is given at the same time, the project will have precedence.
# If project or group is missing, the finder will return empty resultset.
module EE
  module DeploymentsFinder
    private

    def init_collection
      if params[:project].present?
        super
      elsif params[:group].present?
        ::Deployment.for_project(::Project.in_namespace(params[:group].self_and_descendants))
      else
        ::Deployment.none
      end
    end
  end
end
