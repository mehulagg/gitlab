# frozen_string_literal: true

module Mutations
  module Todos
    class Base < ::Mutations::BaseMutation
      private

      def find_object(id:)
        GitlabSchema.object_from_id(id, expected_type: ::Todo)
      end

      def map_to_global_ids(ids)
        return [] if ids.blank?

        ids.map { |id| to_global_id(id) }
      end

      def to_global_id(id)
        Gitlab::GlobalId.as_global_id(id, model_name: Todo.name).to_s
      end
    end
  end
end
