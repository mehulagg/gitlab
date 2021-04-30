# frozen_string_literal: true

class Geo::LfsObjectRegistry < Geo::BaseRegistry
  include ::Geo::Syncable
  include ::Geo::ReplicableRegistry
  include ::ShaAttribute

  sha_attribute :sha256

  MODEL_CLASS = ::LfsObject
  MODEL_FOREIGN_KEY = :lfs_object_id

  belongs_to :lfs_object, class_name: 'LfsObject'

  def self.registry_consistency_worker_enabled?
    if ::Feature.enabled?(:geo_lfs_object_replication)
      replicator_class.enabled?
    else
      true
    end
  end

  def self.failed
    if Feature.enabled?(:geo_lfs_object_replication)
      with_state(:failed)
    else
      where(success: false).where.not(retry_count: nil)
    end
  end

  def self.never_attempted_sync
    if Feature.enabled?(:geo_lfs_object_replication)
      pending.where(last_synced_at: nil)
    else
      where(success: false, retry_count: nil)
    end
  end

  def self.retry_due
    if Feature.enabled?(:geo_lfs_object_replication)
      where(arel_table[:retry_at].eq(nil).or(arel_table[:retry_at].lt(Time.current)))
    else
      where('retry_at is NULL OR retry_at < ?', Time.current)
    end
  end

  def self.synced
    if Feature.enabled?(:geo_lfs_object_replication)
      with_state(:synced).or(where(success: true))
    else
      where(success: true)
    end
  end

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
