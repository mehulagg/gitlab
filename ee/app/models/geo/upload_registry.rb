# frozen_string_literal: true

class Geo::UploadRegistry < Geo::BaseRegistry
  include Geo::Syncable
  include ::Geo::ReplicableRegistry
  include ::Geo::VerifiableRegistry

  MODEL_CLASS = ::Upload
  MODEL_FOREIGN_KEY = :file_id

  self.table_name = 'file_registry'

  belongs_to :upload, foreign_key: :file_id

  scope :fresh, -> { order(created_at: :desc) }

  # Returns untracked uploads as well as tracked uploads that are unused.
  #
  # Untracked uploads is an array where each item is a tuple of [id, file_type]
  # that is supposed to be synced but don't yet have a registry entry.
  #
  # Unused uploads is an array where each item is a tuple of [id, file_type]
  # that is not supposed to be synced but already have a registry entry. For
  # example:
  #
  #   - orphaned registries
  #   - records that became excluded from selective sync
  #   - records that are in object storage, and `sync_object_storage` became
  #     disabled
  #
  # We compute both sets in this method to reduce the number of DB queries
  # performed.
  #
  # @return [Array] the first element is an Array of untracked uploads, and the
  #                 second element is an Array of tracked uploads that are unused.
  #                 For example: [[[1, 'avatar'], [5, 'file']], [[3, 'attachment']]]
  def self.find_registry_differences(range)
    source =
      self::MODEL_CLASS.replicables_for_current_secondary(range)
          .pluck(self::MODEL_CLASS.arel_table[:id], self::MODEL_CLASS.arel_table[:uploader])
          .map! { |id, uploader| [id, uploader.sub(/Uploader\z/, '').underscore] }

    tracked =
      self.model_id_in(range)
          .pluck(:file_id, :file_type)

    untracked = source - tracked
    unused_tracked = tracked - source

    [untracked, unused_tracked]
  end

  # If false, RegistryConsistencyService will frequently check the end of the
  # table to quickly handle new replicables.
  def self.has_create_events?
    false
  end

  def self.insert_for_model_ids(attrs)
    records = attrs.map do |file_id, file_type|
      new(file_id: file_id, file_type: file_type, created_at: Time.zone.now)
    end

    bulk_insert!(records, returns: :ids)
  end

  def self.delete_for_model_ids(attrs)
    attrs.map do |file_id, file_type|
      delete_worker_class.perform_async(file_type, file_id)
    end
  end

  def self.delete_worker_class
    ::Geo::FileRegistryRemovalWorker
  end

  def self.with_search(query)
    return all if query.nil?

    where(file_id: Upload.search(query).limit(1000).pluck_primary_key)
  end

  def self.with_status(status)
    case status
    when 'synced', 'failed'
      self.public_send(status) # rubocop: disable GitlabSecurity/PublicSend
    when 'pending'
      never_attempted_sync
    else
      all
    end
  end

  def file
    upload&.path || s_('Removed %{type} with id %{id}') % { type: file_type, id: file_id }
  end

  def project
    return upload.model if upload&.model.is_a?(Project)
  end

  # Returns a synchronization state based on existing attribute values
  #
  # It takes into account things like if a successful replication has been done
  # if there are pending actions or existing errors
  #
  # @return [Symbol] :synced, :never, or :failed
  def synchronization_state
    return :synced if success?
    return :never if retry_count.nil?

    :failed
  end
end
