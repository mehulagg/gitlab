# frozen_string_literal: true

module Todos
  module Destroy
    class DestroyedIssuableService
      def initialize(target_id, target_type)
        @target_id = target_id
        @target_type = target_type
      end

      def execute
        todos = Todo.for_target(target_id).for_type(target_type)
        user_ids = todos.user_ids

        todos.each_batch do |batch|
          batch.delete_all
        end

        invalidate_todos_cache_counts(user_ids)
      end

      private

      attr_reader :target_id, :target_type

      def invalidate_todos_cache_counts(user_ids)
        User.id_in(user_ids).each(&:invalidate_todos_cache_counts)
      end
    end
  end
end
