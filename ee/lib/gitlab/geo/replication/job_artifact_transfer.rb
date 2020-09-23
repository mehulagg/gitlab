# frozen_string_literal: true

module Gitlab
  module Geo
    module Replication
      # This class is responsible for:
      #   * Requesting an ::Ci::JobArtifact file from the primary
      #   * Saving it in the right place on successful download
      #   * Returning a detailed Result object
      class JobArtifactTransfer < BaseTransfer
        # Initialize a transfer service for a specified Ci::JobArtifact
        #
        # @param [Ci::JobArtifact] job_artifact
        def initialize(job_artifact)
          if job_artifact.local_store?
            super(local_job_artifact_attributes(job_artifact))
          else
            super(remote_job_artifact_attributes(job_artifact))
          end
        end

        private

        def uploader
          resource.file
        end

        def local_job_artifact_attributes(job_artifact)
          {
            resource: job_artifact,
            file_type: :job_artifact,
            file_id: job_artifact.id,
            filename: job_artifact.file.path,
            expected_checksum: job_artifact.file_sha256,
            request_data: job_artifact_request_data(job_artifact)
          }
        end

        def remote_job_artifact_attributes(job_artifact)
          {
            resource: job_artifact,
            file_type: :job_artifact,
            file_id: job_artifact.id,
            request_data: job_artifact_request_data(job_artifact)
          }
        end

        def job_artifact_request_data(job_artifact)
          {
            id: job_artifact.id,
            file_type: :job_artifact,
            file_id: job_artifact.id
          }
        end
      end
    end
  end
end
