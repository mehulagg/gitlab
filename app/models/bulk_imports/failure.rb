# frozen_string_literal: true

class BulkImports::Failure < ApplicationRecord
  self.table_name = 'bulk_import_failures'

  belongs_to :bulk_import_entity, class_name: 'BulkImports::Entity'

  validates :bulk_import_entity, presence: true
end
