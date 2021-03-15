# frozen_string_literal: true

class Geo::LfsObjectRegistry < Geo::BaseRegistry
  # This works for everything, but the ::Geo::Syncable concern
  if Feature.enabled?(:geo_lfs_object_replication_ssf)
    Geo::LfsObjectRegistry.prepend(::Geo::ReplicableRegistry)
  else
    Geo::LfsObjectRegistry.prepend(::ShaAttribute)
    sha_attribute :sha256
    Geo::LfsObjectRegistry.include(::Geo::Syncable)
  end

  MODEL_CLASS = ::LfsObject
  MODEL_FOREIGN_KEY = :lfs_object_id

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
