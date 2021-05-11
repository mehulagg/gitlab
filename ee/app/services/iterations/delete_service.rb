# frozen_string_literal: true

module Iterations
  class DeleteService
    include Gitlab::Allowable

    def initialize(iteration, user)
      @iteration = iteration
      @group = iteration.group
      @current_user = user
    end

    def execute
      response_payload = { group: @group }
      return ::ServiceResponse.error(message: _('Operation not allowed'), payload: response_payload, http_status: 403) unless can_delete_iteration?

      if delete_and_remove_references
        ::ServiceResponse.success(payload: response_payload)
      else
        ::ServiceResponse.error(message: iteration.errors.full_messages, payload: response_payload, http_status: 422)
      end
    end

    private

    attr_reader :iteration, :current_user, :group

    def can_delete_iteration?
      group.licensed_feature_available?(:iterations) &&
        can?(current_user, :admin_iteration, iteration)
    end

    def delete_and_remove_references
      ApplicationRecord.transaction do
        if Board.in_iterations(iteration).update_all(iteration_id: nil) && iteration.destroy
          true
        else
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
