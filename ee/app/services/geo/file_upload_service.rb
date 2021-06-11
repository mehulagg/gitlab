# frozen_string_literal: true

module Geo
  # This class is responsible for:
  #   * Handling file requests from the secondary over the API
  #   * Returning the necessary response data to send the file back
  class FileUploadService < BaseFileService
    attr_reader :decoded_params

    def initialize(params, decoded_params)
      super(params[:type], params[:id])

      @decoded_params = decoded_params
    end

    # Returns { code: :ok, file: CarrierWave File object } upon success
    def execute
      retriever.execute
    end

    def retriever
      retriever_klass.new(object_db_id, decoded_params)
    end

    private

    def retriever_klass
      return Gitlab::Geo::Replication::FileRetriever if user_upload?
      return Gitlab::Geo::Replication::JobArtifactRetriever if job_artifact?

      fail_unimplemented_klass!(type: 'Retriever')
    end
  end
end
