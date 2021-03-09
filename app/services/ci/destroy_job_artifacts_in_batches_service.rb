# frozen_string_literal: true

module Ci
  class DestroyJobArtifactsInBatchesService
    include BaseServiceUtility

    def initialize(artifacts, destroy_locked: false, start_at: nil, loop_timeout: nil, loop_limit: nil, batch_size: 100)
      @artifacts = artifacts
      @destroy_locked = destroy_locked
      @start_at = start_at
      @loop_timeout = loop_timeout
      @loop_limit = loop_limit
      @batch_size = batch_size
      @destroyed_artifacts_count = 0
    end

    def execute
      @artifacts.each_batch(of: @batch_size, column: :expire_at, order: :desc) do |relation, index|
        artifacts = relation.unlocked unless @destroy_locked

        service_response = destroy_batch(artifacts)
        @destroyed_artifacts_count += service_response[:destroyed_artifacts_count]

        break if loop_timeout?
        break if loop_limit?(index)
      end

      success(destroyed_artifacts_count: @destroyed_artifacts_count)
    end

    def destroy_batch(artifacts)
      Ci::JobArtifactsDestroyBatchService.new(artifacts).execute
    end

    def loop_timeout?
      return false unless @start_at && @loop_timeout

      Time.current > @start_at + @loop_timeout
    end

    def loop_limit?(index)
      @loop_limit && index >= @loop_limit
    end
  end
end
