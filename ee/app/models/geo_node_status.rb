class GeoNodeStatus < ActiveRecord::Base
  belongs_to :geo_node

  delegate :selective_sync_type, to: :geo_node

  after_initialize :initialize_feature_flags

  # Whether we were successful in reaching this node
  attr_accessor :success
  attr_writer   :health_status
  attr_accessor :storage_shards

  attr_accessor :repository_verification_enabled

  # Prometheus metrics, no need to store them in the database
  attr_accessor :event_log_count, :event_log_max_id,
                :repository_created_max_id, :repository_updated_max_id,
                :repository_deleted_max_id, :repository_renamed_max_id, :repositories_changed_max_id,
                :lfs_object_deleted_max_id, :job_artifact_deleted_max_id,
                :lfs_objects_registry_count, :job_artifacts_registry_count, :attachments_registry_count,
                :hashed_storage_migrated_max_id, :hashed_storage_attachments_max_id

  # Be sure to keep this consistent with Prometheus naming conventions
  PROMETHEUS_METRICS = {
    db_replication_lag_seconds: 'Database replication lag (seconds)',
    repositories_count: 'Total number of repositories available on primary',
    repositories_synced_count: 'Number of repositories synced on secondary',
    repositories_failed_count: 'Number of repositories failed to sync on secondary',
    wikis_count: 'Total number of wikis available on primary',
    wikis_synced_count: 'Number of wikis synced on secondary',
    wikis_failed_count: 'Number of wikis failed to sync on secondary',
    repositories_verified_count: 'Number of repositories verified on secondary',
    repositories_verification_failed_count: 'Number of repositories failed to verify on secondary',
    wikis_verified_count: 'Number of wikis verified on secondary',
    wikis_verification_failed_count: 'Number of wikis failed to verify on secondary',
    lfs_objects_count: 'Total number of local LFS objects available on primary',
    lfs_objects_synced_count: 'Number of local LFS objects synced on secondary',
    lfs_objects_failed_count: 'Number of local LFS objects failed to sync on secondary',
    lfs_objects_registry_count: 'Number of LFS objects in the registry',
    lfs_objects_synced_missing_on_primary_count: 'Number of LFS objects marked as synced due to the file missing on the primary',
    job_artifacts_count: 'Total number of local job artifacts available on primary',
    job_artifacts_synced_count: 'Number of local job artifacts synced on secondary',
    job_artifacts_failed_count: 'Number of local job artifacts failed to sync on secondary',
    job_artifacts_registry_count: 'Number of job artifacts in the registry',
    job_artifacts_synced_missing_on_primary_count: 'Number of job artifacts marked as synced due to the file missing on the primary',
    attachments_count: 'Total number of local file attachments available on primary',
    attachments_synced_count: 'Number of local file attachments synced on secondary',
    attachments_failed_count: 'Number of local file attachments failed to sync on secondary',
    attachments_registry_count: 'Number of attachments in the registry',
    attachments_synced_missing_on_primary_count: 'Number of attachments marked as synced due to the file missing on the primary',
    replication_slots_count: 'Total number of replication slots on the primary',
    replication_slots_used_count: 'Number of replication slots in use on the primary',
    replication_slots_max_retained_wal_bytes: 'Maximum number of bytes retained in the WAL on the primary',
    last_event_id: 'Database ID of the latest event log entry on the primary',
    last_event_timestamp: 'Time of the latest event log entry on the primary',
    cursor_last_event_id: 'Last database ID of the event log processed by the secondary',
    cursor_last_event_timestamp: 'Time of the event log processed by the secondary',
    last_successful_status_check_timestamp: 'Time when Geo node status was updated internally',
    status_message: 'Summary of health status',
    event_log_count: 'Number of entries in the Geo event log',
    event_log_max_id: 'Highest ID present in the Geo event log',
    repository_created_max_id: 'Highest ID present in repositories created',
    repository_updated_max_id: 'Highest ID present in repositories updated',
    repository_deleted_max_id: 'Highest ID present in repositories deleted',
    repository_renamed_max_id: 'Highest ID present in repositories renamed',
    repositories_changed_max_id: 'Highest ID present in repositories changed',
    lfs_object_deleted_max_id: 'Highest ID present in LFS objects deleted',
    job_artifact_deleted_max_id: 'Highest ID present in job artifacts deleted',
    hashed_storage_migrated_max_id: 'Highest ID present in projects migrated to hashed storage',
    hashed_storage_attachments_max_id: 'Highest ID present in attachments migrated to hashed storage'
  }.freeze

  def self.current_node_status
    current_node = Gitlab::Geo.current_node
    return unless current_node

    status = current_node.find_or_build_status

    # Since we're retrieving our own data, we mark this as a successful load
    status.success = true
    status.load_data_from_current_node

    status.save if Gitlab::Geo.primary?

    status
  end

  def self.fast_current_node_status
    # Primary's status is easy to calculate so we can calculate it on the fly
    return current_node_status if Gitlab::Geo.primary?

    spawn_worker

    attrs = Rails.cache.read(cache_key) || {}
    new(attrs)
  end

  def self.spawn_worker
    ::Geo::MetricsUpdateWorker.perform_async
  end

  def self.cache_key
    "geo-node:#{Gitlab::Geo.current_node.id}:status"
  end

  def self.from_json(json_data)
    json_data.slice!(*allowed_params)

    GeoNodeStatus.new(HashWithIndifferentAccess.new(json_data))
  end

  EXCLUDED_PARAMS = %w[id created_at].freeze
  EXTRA_PARAMS = %w[
    success
    health
    health_status
    last_event_timestamp
    cursor_last_event_timestamp
    storage_shards
  ].freeze

  def self.allowed_params
    self.column_names - EXCLUDED_PARAMS + EXTRA_PARAMS
  end

  def initialize_feature_flags
    self.repository_verification_enabled = Feature.enabled?('geo_repository_verification')
  end

  def update_cache!
    Rails.cache.write(self.class.cache_key, attributes)
  end

  def load_data_from_current_node
    self.status_message =
      begin
        HealthCheck::Utils.process_checks(['geo'])
      rescue NotImplementedError => e
        e.to_s
      end

    latest_event = Geo::EventLog.latest_event
    self.last_event_id = latest_event&.id
    self.last_event_date = latest_event&.created_at
    self.repositories_count = projects_finder.count_repositories
    self.wikis_count = projects_finder.count_wikis
    self.lfs_objects_count = lfs_objects_finder.count_local_lfs_objects
    self.job_artifacts_count = job_artifacts_finder.count_local_job_artifacts
    self.attachments_count = attachments_finder.count_local_attachments
    self.last_successful_status_check_at = Time.now
    self.storage_shards = StorageShard.all

    self.version = Gitlab::VERSION
    self.revision = Gitlab::REVISION

    self.event_log_count = Geo::EventLog.count
    # Geo::PruneEventLogWorker might remove old events, so log maximum id
    self.event_log_max_id = Geo::EventLog.maximum(:id)
    self.repository_created_max_id = Geo::RepositoryCreatedEvent.maximum(:id)
    self.repository_updated_max_id = Geo::RepositoryUpdatedEvent.maximum(:id)
    self.repository_deleted_max_id = Geo::RepositoryDeletedEvent.maximum(:id)
    self.repository_renamed_max_id = Geo::RepositoryRenamedEvent.maximum(:id)
    self.repositories_changed_max_id = Geo::RepositoriesChangedEvent.maximum(:id)
    self.lfs_object_deleted_max_id = Geo::LfsObjectDeletedEvent.maximum(:id)
    self.job_artifact_deleted_max_id = Geo::JobArtifactDeletedEvent.maximum(:id)
    self.hashed_storage_migrated_max_id = Geo::HashedStorageMigratedEvent.maximum(:id)
    self.hashed_storage_attachments_max_id = Geo::HashedStorageAttachmentsEvent.maximum(:id)

    load_primary_data
    load_secondary_data
    load_verification_data

    self
  end

  def load_primary_data
    if Gitlab::Geo.primary?
      self.replication_slots_count = geo_node.replication_slots_count
      self.replication_slots_used_count = geo_node.replication_slots_used_count
      self.replication_slots_max_retained_wal_bytes = geo_node.replication_slots_max_retained_wal_bytes
    end
  end

  def load_secondary_data
    if Gitlab::Geo.secondary?
      self.db_replication_lag_seconds = Gitlab::Geo::HealthCheck.db_replication_lag_seconds
      self.cursor_last_event_id = Geo::EventLogState.last_processed&.event_id
      self.cursor_last_event_date = Geo::EventLog.find_by(id: self.cursor_last_event_id)&.created_at
      self.repositories_synced_count = projects_finder.count_synced_repositories
      self.repositories_failed_count = projects_finder.count_failed_repositories
      self.wikis_synced_count = projects_finder.count_synced_wikis
      self.wikis_failed_count = projects_finder.count_failed_wikis
      self.lfs_objects_synced_count = lfs_objects_finder.count_synced_lfs_objects
      self.lfs_objects_failed_count = lfs_objects_finder.count_failed_lfs_objects
      self.lfs_objects_registry_count = lfs_objects_finder.count_registry_lfs_objects
      self.lfs_objects_synced_missing_on_primary_count = lfs_objects_finder.count_synced_missing_on_primary_lfs_objects
      self.job_artifacts_synced_count = job_artifacts_finder.count_synced_job_artifacts
      self.job_artifacts_failed_count = job_artifacts_finder.count_failed_job_artifacts
      self.job_artifacts_registry_count = job_artifacts_finder.count_registry_job_artifacts
      self.job_artifacts_synced_missing_on_primary_count = job_artifacts_finder.count_synced_missing_on_primary_job_artifacts
      self.attachments_synced_count = attachments_finder.count_synced_attachments
      self.attachments_failed_count = attachments_finder.count_failed_attachments
      self.attachments_registry_count = attachments_finder.count_registry_attachments
      self.attachments_synced_missing_on_primary_count = attachments_finder.count_synced_missing_on_primary_attachments
    end
  end

  def load_verification_data
    return unless repository_verification_enabled

    finder = Gitlab::Geo.primary? ? repository_verification_finder : projects_finder
    self.repositories_verified_count = finder.count_verified_repositories
    self.repositories_verification_failed_count = finder.count_verification_failed_repositories
    self.wikis_verified_count = finder.count_verified_wikis
    self.wikis_verification_failed_count = finder.count_verification_failed_wikis
  end

  alias_attribute :health, :status_message

  def healthy?
    status_message.blank? || status_message == 'Healthy'.freeze
  end

  def health_status
    @health_status || (healthy? ? 'Healthy' : 'Unhealthy')
  end

  def last_successful_status_check_timestamp
    self.last_successful_status_check_at.to_i
  end

  def last_successful_status_check_timestamp=(value)
    self.last_successful_status_check_at = Time.at(value)
  end

  def last_event_timestamp
    self.last_event_date.to_i
  end

  def last_event_timestamp=(value)
    self.last_event_date = Time.at(value)
  end

  def cursor_last_event_timestamp
    self.cursor_last_event_date.to_i
  end

  def cursor_last_event_timestamp=(value)
    self.cursor_last_event_date = Time.at(value)
  end

  def repositories_synced_in_percentage
    calc_percentage(repositories_count, repositories_synced_count)
  end

  def wikis_synced_in_percentage
    calc_percentage(wikis_count, wikis_synced_count)
  end

  def repositories_verified_in_percentage
    calc_percentage(repositories_count, repositories_verified_count)
  end

  def wikis_verified_in_percentage
    calc_percentage(wikis_count, wikis_verified_count)
  end

  def lfs_objects_synced_in_percentage
    calc_percentage(lfs_objects_count, lfs_objects_synced_count)
  end

  def job_artifacts_synced_in_percentage
    calc_percentage(job_artifacts_count, job_artifacts_synced_count)
  end

  def attachments_synced_in_percentage
    calc_percentage(attachments_count, attachments_synced_count)
  end

  def replication_slots_used_in_percentage
    calc_percentage(replication_slots_count, replication_slots_used_count)
  end

  # This method only is useful when the storage shard information is loaded
  # from a remote node via JSON.
  def storage_shards_match?
    return unless Gitlab::Geo.primary?
    return unless current_shards && primary_shards

    shards_match?(current_shards, primary_shards)
  end

  def [](key)
    public_send(key) # rubocop:disable GitlabSecurity/PublicSend
  end

  private

  def current_shards
    serialize_storage_shards(storage_shards)
  end

  def primary_shards
    serialize_storage_shards(StorageShard.all)
  end

  def serialize_storage_shards(shards)
    StorageShardSerializer.new.represent(shards).as_json
  end

  def shards_match?(first, second)
    # Developers may want to run Geo locally using different paths
    return names_match?(first, second) if Rails.env.development?

    sort_by_name(first) == sort_by_name(second)
  end

  def sort_by_name(shards)
    shards.sort_by { |shard| shard['name'] }
  end

  def names_match?(first, second)
    extract_names(first) == extract_names(second)
  end

  def extract_names(shards)
    shards.map { |shard| shard['name'] }.sort
  end

  def attachments_finder
    @attachments_finder ||= Geo::AttachmentRegistryFinder.new(current_node: geo_node)
  end

  def lfs_objects_finder
    @lfs_objects_finder ||= Geo::LfsObjectRegistryFinder.new(current_node: geo_node)
  end

  def job_artifacts_finder
    @job_artifacts_finder ||= Geo::JobArtifactRegistryFinder.new(current_node: geo_node)
  end

  def projects_finder
    @projects_finder ||= Geo::ProjectRegistryFinder.new(current_node: geo_node)
  end

  def repository_verification_finder
    @repository_verification_finder ||= Geo::RepositoryVerificationFinder.new
  end

  def calc_percentage(total, count)
    return 0 if !total.present? || total.zero?

    (count.to_f / total.to_f) * 100.0
  end
end
