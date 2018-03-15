require 'fog/aws'
require 'carrierwave/storage/fog'

#
# This concern should add object storage support
# to the GitlabUploader class
#
module ObjectStorage
  RemoteStoreError = Class.new(StandardError)
  UnknownStoreError = Class.new(StandardError)
  ObjectStorageUnavailable = Class.new(StandardError)

  DIRECT_UPLOAD_TIMEOUT = 4.hours
  TMP_UPLOAD_PATH = 'tmp/upload'.freeze

  module Store
    LOCAL = 1
    REMOTE = 2
  end

  module Extension
    # this extension is the glue between the ObjectStorage::Concern and RecordsUploads::Concern
    module RecordsUploads
      extend ActiveSupport::Concern

      prepended do |base|
        raise "#{base} must include ObjectStorage::Concern to use extensions." unless base < Concern

        base.include(::RecordsUploads::Concern)
      end

      def retrieve_from_store!(identifier)
        paths = store_dirs.map { |store, path| File.join(path, identifier) }

        unless current_upload_satisfies?(paths, model)
          # the upload we already have isn't right, find the correct one
          self.upload = uploads.find_by(model: model, path: paths)
        end

        super
      end

      def build_upload
        super.tap do |upload|
          upload.store = object_store
        end
      end

      def upload=(upload)
        return unless upload

        self.object_store = upload.store
        super
      end

      def schedule_background_upload(*args)
        return unless schedule_background_upload?

        ObjectStorage::BackgroundMoveWorker.perform_async(self.class.name,
                                                upload.class.to_s,
                                                mounted_as,
                                                upload.id)
      end

      private

      def current_upload_satisfies?(paths, model)
        return false unless upload
        return false unless model

        paths.include?(upload.path) &&
          upload.model_id == model.id &&
          upload.model_type == model.class.base_class.sti_name
      end
    end
  end

  # Add support for automatic background uploading after the file is stored.
  #
  module BackgroundMove
    extend ActiveSupport::Concern

    def background_upload(mount_points = [])
      return unless mount_points.any?

      run_after_commit do
        mount_points.each { |mount| send(mount).schedule_background_upload } # rubocop:disable GitlabSecurity/PublicSend
      end
    end

    def changed_mounts
      self.class.uploaders.select do |mount, uploader_class|
        mounted_as = uploader_class.serialization_column(self.class, mount)
        uploader = send(:"#{mounted_as}") # rubocop:disable GitlabSecurity/PublicSend

        next unless uploader
        next unless uploader.exists?
        next unless send(:"#{mounted_as}_changed?") # rubocop:disable GitlabSecurity/PublicSend

        mount
      end.keys
    end

    included do
      after_save on: [:create, :update] do
        background_upload(changed_mounts)
      end
    end
  end

  module Concern
    extend ActiveSupport::Concern

    included do |base|
      base.include(ObjectStorage)

      before :store, :verify_license!
      after :migrate, :delete_migrated_file
    end

    class_methods do
      def object_store_options
        options.object_store
      end

      def object_store_enabled?
        object_store_options.enabled
      end

      def direct_upload_enabled?
        object_store_options.direct_upload
      end

      def background_upload_enabled?
        object_store_options.background_upload
      end

      def proxy_download_enabled?
        object_store_options.proxy_download
      end

      def direct_download_enabled?
        !proxy_download_enabled?
      end

      def object_store_credentials
        object_store_options.connection.to_hash.deep_symbolize_keys
      end

      def remote_store_path
        object_store_options.remote_directory
      end

      def licensed?
        License.feature_available?(:object_storage)
      end

      def serialization_column(model_class, mount_point)
        model_class.uploader_options.dig(mount_point, :mount_on) || mount_point
      end

      def workhorse_authorize
        if options = workhorse_remote_upload_options
          { RemoteObject: options }
        else
          { TempPath: workhorse_local_upload_path }
        end
      end

      def workhorse_local_upload_path
        File.join(self.root, TMP_UPLOAD_PATH)
      end

      def workhorse_remote_upload_options
        return unless self.object_store_enabled?
        return unless self.direct_upload_enabled?

        id = [CarrierWave.generate_cache_id, SecureRandom.hex].join('-')
        upload_path = File.join(TMP_UPLOAD_PATH, id)
        connection = ::Fog::Storage.new(self.object_store_credentials)
        expire_at = Time.now + DIRECT_UPLOAD_TIMEOUT
        options = { 'Content-Type' => 'application/octet-stream' }

        {
          ID: id,
          GetURL: connection.get_object_url(remote_store_path, upload_path, expire_at),
          DeleteURL: connection.delete_object_url(remote_store_path, upload_path, expire_at),
          StoreURL: connection.put_object_url(remote_store_path, upload_path, expire_at, options)
        }
      end
    end

    # allow to configure and overwrite the filename
    def filename
      @filename || super || file&.filename # rubocop:disable Gitlab/ModuleWithInstanceVariables
    end

    def filename=(filename)
      @filename = filename # rubocop:disable Gitlab/ModuleWithInstanceVariables
    end

    def file_storage?
      storage.is_a?(CarrierWave::Storage::File)
    end

    def file_cache_storage?
      cache_storage.is_a?(CarrierWave::Storage::File)
    end

    def object_store
      @object_store ||= model.try(store_serialization_column) || Store::LOCAL
    end

    # rubocop:disable Gitlab/ModuleWithInstanceVariables
    def object_store=(value)
      @object_store = value || Store::LOCAL
      @storage = storage_for(object_store)
    end
    # rubocop:enable Gitlab/ModuleWithInstanceVariables

    # Return true if the current file is part or the model (i.e. is mounted in the model)
    #
    def persist_object_store?
      model.respond_to?(:"#{store_serialization_column}=")
    end

    # Save the current @object_store to the model <mounted_as>_store column
    def persist_object_store!
      return unless persist_object_store?

      updated = model.update_column(store_serialization_column, object_store)
      raise 'Failed to update object store' unless updated
    end

    def use_file
      if file_storage?
        return yield path
      end

      begin
        cache_stored_file!
        yield cache_path
      ensure
        cache_storage.delete_dir!(cache_path(nil))
      end
    end

    #
    # Move the file to another store
    #
    #   new_store: Enum (Store::LOCAL, Store::REMOTE)
    #
    def migrate!(new_store)
      uuid = Gitlab::ExclusiveLease.new(exclusive_lease_key, timeout: 1.hour.to_i).try_obtain
      raise 'Already running' unless uuid

      unsafe_migrate!(new_store)
    ensure
      Gitlab::ExclusiveLease.cancel(exclusive_lease_key, uuid)
    end

    def schedule_background_upload(*args)
      return unless schedule_background_upload?

      ObjectStorage::BackgroundMoveWorker.perform_async(self.class.name,
                                                          model.class.name,
                                                          mounted_as,
                                                          model.id)
    end

    def fog_directory
      self.class.remote_store_path
    end

    def fog_credentials
      self.class.object_store_credentials
    end

    def fog_public
      false
    end

    def delete_migrated_file(migrated_file)
      migrated_file.delete if exists?
    end

    def verify_license!(_file)
      return if file_storage?

      raise(ObjectStorageUnavailable, 'Object Storage feature is missing') unless self.class.licensed?
    end

    def exists?
      file.present?
    end

    def store_dir(store = nil)
      store_dirs[store || object_store]
    end

    def store_dirs
      {
        Store::LOCAL => File.join(base_dir, dynamic_segment),
        Store::REMOTE => File.join(dynamic_segment)
      }
    end

    def store_workhorse_file!(params, identifier)
      filename = params["#{identifier}.name"]

      if remote_object_id = params["#{identifier}.remote_id"]
        store_remote_file!(remote_object_id, filename)
      elsif local_path = params["#{identifier}.path"]
        store_local_file!(local_path, filename)
      else
        raise RemoteStoreError, 'Bad file'
      end
    end

    private

    def schedule_background_upload?
      self.class.object_store_enabled? &&
        self.class.background_upload_enabled? &&
        self.class.licensed? &&
        self.file_storage?
    end

    def store_remote_file!(remote_object_id, filename)
      raise RemoteStoreError, 'Missing filename' unless filename

      file_path = File.join(TMP_UPLOAD_PATH, remote_object_id)
      file_path = Pathname.new(file_path).cleanpath.to_s
      raise RemoteStoreError, 'Bad file path' unless file_path.start_with?(TMP_UPLOAD_PATH + '/')

      self.object_store = Store::REMOTE

      # TODO:
      # This should be changed to make use of `tmp/cache` mechanism
      # instead of using custom upload directory,
      # using tmp/cache makes this implementation way easier than it is today
      CarrierWave::Storage::Fog::File.new(self, storage, file_path).tap do |file|
        raise RemoteStoreError, 'Missing file' unless file.exists?

        self.filename = filename
        self.file = storage.store!(file)
      end
    end

    def store_local_file!(local_path, filename)
      raise RemoteStoreError, 'Missing filename' unless filename

      root_path = File.realpath(self.class.workhorse_local_upload_path)
      file_path = File.realpath(local_path)
      raise RemoteStoreError, 'Bad file path' unless file_path.start_with?(root_path)

      self.object_store = Store::LOCAL
      self.store!(UploadedFile.new(file_path, filename))
    end

    # this is a hack around CarrierWave. The #migrate method needs to be
    # able to force the current file to the migrated file upon success.
    def file=(file)
      @file = file # rubocop:disable Gitlab/ModuleWithInstanceVariables
    end

    def serialization_column
      self.class.serialization_column(model.class, mounted_as)
    end

    # Returns the column where the 'store' is saved
    #   defaults to 'store'
    def store_serialization_column
      [serialization_column, 'store'].compact.join('_').to_sym
    end

    def storage
      @storage ||= storage_for(object_store)
    end

    def storage_for(store)
      case store
      when Store::REMOTE
        raise 'Object Storage is not enabled' unless self.class.object_store_enabled?

        CarrierWave::Storage::Fog.new(self)
      when Store::LOCAL
        CarrierWave::Storage::File.new(self)
      else
        raise UnknownStoreError
      end
    end

    def exclusive_lease_key
      "object_storage_migrate:#{model.class}:#{model.id}"
    end

    #
    # Move the file to another store
    #
    #   new_store: Enum (Store::LOCAL, Store::REMOTE)
    #
    def unsafe_migrate!(new_store)
      return unless object_store != new_store
      return unless file

      new_file = nil
      file_to_delete = file
      from_object_store = object_store
      self.object_store = new_store # changes the storage and file

      cache_stored_file! if file_storage?

      with_callbacks(:migrate, file_to_delete) do
        with_callbacks(:store, file_to_delete) do # for #store_versions!
          new_file = storage.store!(file)
          persist_object_store!
          self.file = new_file
        end
      end

      file
    rescue => e
      # in case of failure delete new file
      new_file.delete unless new_file.nil?
      # revert back to the old file
      self.object_store = from_object_store
      self.file = file_to_delete
      raise e
    end
  end
end
