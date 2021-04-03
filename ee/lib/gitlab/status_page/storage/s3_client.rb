# frozen_string_literal: true

module Gitlab
  module StatusPage
    module Storage
      # Implements a minimal AWS S3 client.
      class S3Client
        include Gitlab::StatusPage::Storage::WrapsStorageErrors

        def initialize(region:, bucket_name:, access_key_id:, secret_access_key:)
          @bucket_name = bucket_name
          @client = Aws::S3::Client.new(
            region: region,
            credentials: Aws::Credentials.new(access_key_id, secret_access_key)
          )
        end

        # Stores +content+ as +key+ in storage
        #
        # Note: We are making sure that
        # * we control +content+ (not the user)
        # * this upload is done as a background job (not in a web request)
        def upload_object(key, content)
          wrap_errors(key: key) do
            client.put_object(bucket: bucket_name, key: key, body: content)
          end

          true
        end

        # Deletes object at +key+ from storage
        #
        # Note, this operation succeeds even if +key+ does not exist in storage.
        def delete_object(key)
          wrap_errors(key: key) do
            client.delete_object(bucket: bucket_name, key: key)
          end

          true
        end

        # Delete all objects whose key has a given +prefix+
        def recursive_delete(prefix)
          wrap_errors(prefix: prefix) do
            # Aws::S3::Types::ListObjectsV2Output is paginated and Enumerable
            list_objects(prefix).each.with_index do |response, index|
              break if index >= Gitlab::StatusPage::Storage::MAX_PAGES

              objects = response.contents.map { |obj| { key: obj.key } }
              # Batch delete in sets determined by default max_key argument that can be passed to list_objects_v2
              client.delete_objects({ bucket: bucket_name, delete: { objects: objects } }) unless objects.empty?
            end
          end

          true
        end

        # Return a Set of all keys with a given prefix
        def list_object_keys(prefix)
          wrap_errors(prefix: prefix) do
            list_objects(prefix).reduce(Set.new) do |objects, (response, _index)|
              break objects if objects.size >= Gitlab::StatusPage::Storage::MAX_UPLOADS

              objects | response.contents.map(&:key)
            end
          end
        end

        # Stores +file+ as +key+ in storage using multipart upload
        #
        # key: s3 key at which file is stored
        # file: An open file or file-like io object
        def multipart_upload(key, file)
          Gitlab::StatusPage::Storage::S3MultipartUpload.new(
            client: client, bucket_name: bucket_name, key: key, open_file: file
          ).call
        end

        private

        attr_reader :client, :bucket_name

        def list_objects(prefix)
          client.list_objects_v2(bucket: bucket_name, prefix: prefix, max_keys: Gitlab::StatusPage::Storage::MAX_KEYS_PER_PAGE)
        end
      end
    end
  end
end
