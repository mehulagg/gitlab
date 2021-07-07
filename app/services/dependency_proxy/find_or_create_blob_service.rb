# frozen_string_literal: true

module DependencyProxy
  class FindOrCreateBlobService < DependencyProxy::BaseService
    def initialize(group, image, token, blob_sha)
      @group = group
      @image = image
      @token = token
      @blob_sha = blob_sha
      @blob = nil
    end

    def execute
      file_name = @blob_sha.sub('sha256:', '') + '.gz'
      @blob = @group.dependency_proxy_blobs.find_or_build(file_name)

      unless @blob.persisted?
        if Feature.enabled(:unlink_dep_proxy, group)
          pull_new_blob
        else
          result = DependencyProxy::DownloadBlobService
            .new(@image, @blob_sha, @token).execute

          if result[:status] == :error
            log_failure(result)

            return error('Failed to download the blob', result[:http_status])
          end

          @blob.file = result[:file]
          @blob.size = result[:file].size
          @blob.save!
        end
      end

      success(blob: @blob)
    end

    private

    def pull_new_blob
      DependencyProxy::DownloadBlobService.new(@image, @blob_sha, @token).execute_with_blob do |new_blob|
        @blob.update!(
          content_type: new_blob[:content_type],
          file: new_blob[:file],
          size: new_blob[:file].size
        )
      end
    end

    def log_failure(result)
      log_error(
        "Dependency proxy: Failed to download the blob." \
        "Blob sha: #{@blob_sha}." \
        "Error message: #{result[:message][0, 100]}" \
        "HTTP status: #{result[:http_status]}"
      )
    end
  end
end
