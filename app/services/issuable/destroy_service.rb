# frozen_string_literal: true

module Issuable
  class DestroyService < IssuableBaseService
    def execute(issuable)
      TodoService.new.destroy_target(issuable) do |issuable|
        if issuable.destroy
          delete_all_todos(issuable)
          issuable.update_project_counter_caches
          issuable.assignees.each(&:invalidate_cache_counts)
        end
      end
    end

    private

    def delete_all_todos(issuable)
      # To follow https://docs.gitlab.com/ee/development/foreign_keys.html#dependent-removals,
      # we are deleting associated Todo records here instead of having it
      # in `has_many :todos` definition.
      #
      # Need to call `delete_all` on `Todo` collection instead of `todos`
      # association of issuable because the latter triggers an UPDATE
      # query and resuls to a `PG::NotNullViolation` error.
      Todo
        .for_target(issuable.id)
        .for_type(issuable.class.name)
        .delete_all
    end
  end
end
