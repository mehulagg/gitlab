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
        mount if send(:"#{mounted_as}_changed?") # rubocop:disable GitlabSecurity/PublicSend
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

      def background_upload_enabled?
        object_store_options.background_upload
      end

      def object_store_credentials
        object_store_options.connection.to_hash.deep_symbolize_keys
      end

      def remote_store_path
        object_store_options.remote_directory
      end

      def licensed?
        # TODO to bring back
        true || License.feature_available?(:object_storage)
      end

      def serialization_column(model_class, mount_point)
        model_class.uploader_options.dig(mount_point, :mount_on) || mount_point
      end
    end

    def cache_dir
      if file_cache_storage?
        File.join(root, base_dir, 'tmp/cache')
      else
        'tmp/cache'
      end
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

      updated = model.update({ store_serialization_column => object_store })
      raise ActiveRecordError unless updated
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

    def filename
      super || file&.filename
    end

    #
    # Move the file to another store
    #
    #   new_store: Enum (Store::LOCAL, Store::REMOTE)
    #
    def migrate!(new_store)
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

    # Direct Upload

    def upload_authorize
      self.cache_id = CarrierWave.generate_cache_id
      self.original_filename = SecureRandom.hex

      result = {}

      # result['TempPath'] = cache_path

      remote_path = cache_path
      remote_path.slice!(self.root)
      remote_path.slice!('/')

      remote_storage = storage_for(Store::REMOTE)

      expire_at = ::Fog::Time.now + 24.hours
      result[:ObjectStore] = {
        ObjectID: cache_name,
        GetURL: remote_storage.connection.get_object_https_url(fog_directory, remote_path, expire_at),
        DeleteURL: remote_storage.connection.delete_object_url(fog_directory, remote_path, expire_at),
        StoreURL: remote_storage.connection.put_object_url(fog_directory, remote_path, expire_at, {
            'Content-Type' => 'application/octet-stream'
          })
      }

      result
    end

    def cache!(new_file = nil)
      unless retrive_uploaded_file!(new_file&.object_id, new_file.original_filename)
        super
      end
    end

    def retrive_uploaded_file!(identifier, filename)
      return unless identifier
      return unless filename

      puts "xx: #{identifier}"
      puts "xx: #{filename}"
      @use_storage_for_cache = true

      puts "xxy1"
      self.object_store = Store::REMOTE

      puts "xxy2"
      retrieve_from_cache!(identifier)
      @filename = filename
    ensure
      @use_storage_for_cache = false
    end

    def store_remote_file!(identifier, filename)
      retrive_uploaded_file!(identifier, filename)
      store!
      persist_object_store!
    end

    def cache_storage
      if @use_storage_for_cache || cached?
        storage
      else
        super
      end
    end    

    private

    def schedule_background_upload?
      self.class.object_store_enabled? &&
        self.class.background_upload_enabled? &&
        self.class.licensed? &&
        self.file_storage?
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
  end
end
