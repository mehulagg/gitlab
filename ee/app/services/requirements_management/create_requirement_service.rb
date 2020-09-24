# frozen_string_literal: true

module RequirementsManagement
  class CreateRequirementService < BaseService
    include Gitlab::Allowable

    def execute
      raise Gitlab::Access::AccessDeniedError unless can?(current_user, :create_requirement, project)

      attrs = whitelisted_requirement_params.merge(author: current_user)
      project.requirements.create(attrs)
    end

    private

    def whitelisted_requirement_params
      params.slice(:title)
    end
  end
end
