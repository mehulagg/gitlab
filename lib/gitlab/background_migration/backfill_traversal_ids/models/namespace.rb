# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    module BackfillTraversalIds
      class Namespace < ActiveRecord::Base
        include ::EachBatch

        self.table_name = 'namespaces'
      end
    end
  end
end
