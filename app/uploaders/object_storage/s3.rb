# frozen_string_literal: true

module ObjectStorage
  module S3
    def aws_bucket
      self.class.remote_store_path
    end

    def aws_credentials
      {
        access_key_id: object_storage_credentials[:aws_access_key_id],
        secret_access_key: object_storage_credentials[:aws_secret_access_key],
        region: object_storage_credentials[:region],
        force_path_style: object_storage_credentials[:path_style],
        endpoint: object_storage_credentials[:endpoint],
        stub_responses: Rails.env.test?
      }.compact
    end

    def aws_attributes
      {
        server_side_encryption: object_storage_config.server_side_encryption,
        ssekms_key_id: object_storage_config.server_side_encryption_kms_key_id
      }.compact
    end

    def aws_acl
      nil
    end
  end
end
