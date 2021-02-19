# frozen_string_literal: true

module ExternalApprovalRules
  class UpdateService < BaseContainerService
    def execute
      return ServiceResponse.error(message: 'Failed to update rule', payload: { errors: ['Not allowed'] }, http_status: :unauthorized) unless current_user.can?(:admin_project, container.project)

      if container.update(params)
        ServiceResponse.success(payload: { rule: container })
      else
        ServiceResponse.error(message: 'Failed to update rule', payload: { errors: container.errors.full_messages }, http_status: :unprocessable_entity)
      end
    end
  end
end
