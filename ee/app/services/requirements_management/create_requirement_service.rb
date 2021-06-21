# frozen_string_literal: true

module RequirementsManagement
  class CreateRequirementService < ::BaseProjectService
    include Gitlab::Allowable

    # NOTE: Even though this class does not (yet) do spam checking, this constructor takes a
    # spam_params named argument in order to be consistent with the other issuable service
    # constructors. This is necessary in order for methods such as create_issuable to be able to
    # work in a consistent way with all different issuable services.
    # See https://gitlab.com/groups/gitlab-org/-/epics/5527#current-vulnerabilities
    # for more context.
    def initialize(project:, current_user: nil, params: {}, spam_params: nil)
      super(project: project, current_user: current_user, params: params)
    end

    def execute
      raise Gitlab::Access::AccessDeniedError unless can?(current_user, :create_requirement, project)

      attrs = whitelisted_requirement_params.merge(author: current_user)
      project.requirements.create(attrs)
    end

    private

    def whitelisted_requirement_params
      params.slice(:title, :description)
    end
  end
end
