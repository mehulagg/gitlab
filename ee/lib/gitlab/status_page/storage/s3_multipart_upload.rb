# frozen_string_literal: true

module Gitlab
  module StatusPage
    module Storage
      # Implements multipart upload in s3
      class S3MultipartUpload
        include Gitlab::StatusPage::Storage::WrapsStorageErrors
        # 5 megabytes is the minimum part size specified in the amazon SDK
        MULTIPART_UPLOAD_PART_SIZE = 5.megabytes

        def initialize(client:, bucket_name:, key:, open_file:)
          @client = client
          @bucket_name = bucket_name
          @key = key
          @file = open_file
        end

        # Stores +file+ as +key+ in storage using multipart upload
        #
        # key: s3 key at which file is stored
        # file: An open file or file-like io object
        def call
          # AWS sdk v2 has upload_file which supports multipart
          # However Gitlab::HttpIO used when object storage is enabled
          # cannot be used with upload_file
          wrap_errors(key: key) do
            upload_id = create_upload.to_h[:upload_id]
            begin
              parts = upload_part(upload_id)
              complete_upload(upload_id, parts)
              # Rescue on Exception since even on keyboard interrupt we want to abort the upload and re-raise
              # abort clears the already uploaded parts so that they do not cost the bucket owner
              # The status page bucket lifecycle policy will clear out unaborted parts if
              # this fails without an exception (power failures etc.)
            rescue Exception => e # rubocop:disable Lint/RescueException
              abort_upload(upload_id)
              raise e
            end
          end
        end

        private

        attr_reader :key, :file, :client, :bucket_name

        def create_upload
          client.create_multipart_upload({ bucket: bucket_name, key: key })
        end

        def upload_part(upload_id)
          parts = []
          part_number = 1

          file.seek(0)
          until file.eof?
            part = client.upload_part({
              body: file.read(MULTIPART_UPLOAD_PART_SIZE),
              bucket: bucket_name,
              key: key,
              part_number: part_number, # required
              upload_id: upload_id
            })

            parts << part.to_h.merge(part_number: part_number)
            part_number += 1
          end

          parts
        end

        def complete_upload(upload_id, parts)
          client.complete_multipart_upload({
            bucket: bucket_name,
            key: key,
            multipart_upload: {
              parts: parts
            },
            upload_id: upload_id
          })
        end

        def abort_upload(upload_id)
          client.abort_multipart_upload(
            bucket: bucket_name,
            key: key,
            upload_id: upload_id
          )
        end
      end
    end
  end
end
