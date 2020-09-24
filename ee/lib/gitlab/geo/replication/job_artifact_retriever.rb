# frozen_string_literal: true

module Gitlab
  module Geo
    module Replication
      # This class is responsible for:
      #   * Finding an ::Ci::JobArtifact record
      #   * Returning the necessary response data to send the file back
      #
      class JobArtifactRetriever < BaseRetriever
        def execute
          return error('Job artifact not found') unless job_artifact.present?

          unless job_artifact.file.present? && job_artifact.file.exists?
            log_error("Could not upload job artifact because it does not have a file", id: job_artifact.id)

            return file_not_found(job_artifact)
          end

          success(job_artifact.file)
        end

        private

        def job_artifact
          strong_memoize(:job_artifact) do
            ::Ci::JobArtifact.find_by_id(object_db_id)
          end
        end
      end
    end
  end
end
