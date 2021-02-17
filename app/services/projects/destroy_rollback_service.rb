# frozen_string_literal: true

module Projects
  class DestroyRollbackService < BaseService
    def execute
      return unless project

      Projects::ForksCountService.new(project).delete_cache
    end
  end
end
