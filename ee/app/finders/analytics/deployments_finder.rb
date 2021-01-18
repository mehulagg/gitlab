# frozen_string_literal: true

module Analytics
  class DeploymentsFinder
    def initialize(project_or_group:, environment_name:, from:, to: nil)
      @project_or_group = project_or_group
      @environment_name = environment_name
      @from = from
      @to = to
    end

    attr_reader :project_or_group, :environment_name, :from, :to

    def execute
      filter_deployments(all_deployments)
    end

    private

    def all_deployments
      if project_or_group.is_a?(Group)
        Deployment.for_projects(project_or_group.projects)
      else
        project_or_group.deployments
      end
    end

    def filter_deployments(deployments)
      deployments = filter_by_time(deployments)
      deployments = filter_by_success(deployments)
      deployments = filter_by_environment_name(deployments)
      # rubocop: disable CodeReuse/ActiveRecord
      deployments = deployments.order('finished_at')
      # rubocop: enable CodeReuse/ActiveRecord
      deployments
    end

    def filter_by_time(deployments)
      deployments.finished_between(from, to)
    end

    def filter_by_success(deployments)
      deployments.success
    end

    def filter_by_environment_name(deployments)
      deployments.for_environment_name(environment_name)
    end
  end
end
