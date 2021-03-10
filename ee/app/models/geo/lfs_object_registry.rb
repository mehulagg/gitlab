# frozen_string_literal: true

class Geo::LfsObjectRegistry < Geo::BaseRegistry
  include ::Geo::ReplicableRegistry
  include ::ShaAttribute
  # include ::Geo::Syncable #TODO: This breaks due to scopes from Syncable overwriting behavior from ReplicableRegistry

  MODEL_CLASS = ::LfsObject
  MODEL_FOREIGN_KEY = :lfs_object_id

  sha_attribute :sha256

  belongs_to :lfs_object, class_name: 'LfsObject'

  # If false, RegistryConsistencyService will frequently check the end of the
  # table to quickly handle new replicables.
  def self.has_create_events?
    false
  end

  def self.delete_for_model_ids(lfs_object_ids)
    lfs_object_ids.map do |lfs_object_id|
      delete_worker_class.perform_async(:lfs, lfs_object_id)
    end
  end

  def self.delete_worker_class
    ::Geo::FileRegistryRemovalWorker
  end
end
