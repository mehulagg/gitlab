# frozen_string_literal: true

module ExternalApprovalRules
  class DestroyService < BaseContainerService
    def execute
      return ServiceResponse.error(message: 'Failed to destroy rule', payload: { errors: ['Not allowed'] }, http_status: :unauthorized) unless current_user.can?(:admin_project, container.project)

      if container.destroy
        ServiceResponse.success
      else
        ServiceResponse.error(message: 'Failed to destroy rule', payload: { errors: container.errors.full_messages }, http_status: :unprocessable_entity)
      end
    end
  end
end
