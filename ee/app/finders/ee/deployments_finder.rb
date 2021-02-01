# frozen_string_literal: true

module EE
  module DeploymentsFinder
    def execute
      items = super
      items = by_environment_name(items) if params[:environment_name]
      items = by_finished_between(items)
      items
    end

    private

    def init_collection
      if params[:project].present?
        super
      elsif params[:group].present?
        ::Deployment.for_project(::Project.id_in(params[:group].self_and_descendants))
      else
        ::Deployment.none
      end
    end

    def by_environment_name(items)
      items = items.for_environment_name(params[:environment_name]) if params[:environment_name]

      items
    end

    def by_finished_between(items)
      items = items.finished_between(params[:finished_after], params[:finished_before]) if params[:finished_after] || params[:finished_before]

      items
    end
  end
end
