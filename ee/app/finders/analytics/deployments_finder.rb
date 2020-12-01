# frozen_string_literal: true

module Analytics
  class DeploymentsFinder
    def initialize(project:, environment_name:, from:, to: nil)
      @project = project
      @environment_name = environment_name
      @from = from
      @to = to
    end

    attr_reader :project, :environment_name, :from, :to

    def execute
      filter_deployments(project.deployments)
    end

    private

    def filter_deployments(all_deployments)
      deployments = filter_by_time(all_deployments)
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
