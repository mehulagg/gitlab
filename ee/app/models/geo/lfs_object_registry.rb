# frozen_string_literal: true

class Geo::LfsObjectRegistry < Geo::BaseRegistry
  include ::Geo::ReplicableRegistry

  MODEL_CLASS = ::LfsObject
  MODEL_FOREIGN_KEY = :lfs_object_id

  self.table_name = 'lfs_object_registry'

  belongs_to :lfs_object, class_name: 'LfsObject'
end
