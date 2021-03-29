# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class BackfillTopLevelTraversalIds
      def perform(min_namespace_id, max_namespace_id)
        Namespace.where(id: min_namespace_id..max_namespace_id)
                 .where(parent_id: nil)
                 .update_all('traversal_ids = ARRAY[id]')
      end
    end
  end
end
