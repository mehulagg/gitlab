# frozen_string_literal: true

module Issuable
  class DestroyService < IssuableBaseService
    def execute(issuable)
      if issuable.destroy
        delete_todos(issuable)
        issuable.update_project_counter_caches
        issuable.assignees.each(&:invalidate_cache_counts)
      end
    end

    private

    def delete_todos(issuable)
      TodosDestroyer::DestroyedIssuableWorker
        .perform_async(issuable.id, issuable.class.name)
    end
  end
end
