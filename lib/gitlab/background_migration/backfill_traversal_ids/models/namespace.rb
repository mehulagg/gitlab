# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    module BackfillTraversalIds
      module Models
        # Background migration safe version of Namespace model.
        class Namespace < ActiveRecord::Base
          include ::EachBatch

          self.table_name = 'namespaces'
        end
      end
    end
  end
end
