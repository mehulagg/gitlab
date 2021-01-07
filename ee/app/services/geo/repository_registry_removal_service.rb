# frozen_string_literal: true

module Geo
  # This service is intended to remove any repository, including its
  # registry record when container object doesn't exist anymore.
  class RepositoryRegistryRemovalService
    include ::Gitlab::Geo::LogHelpers

    attr_reader :params, :replicator, :id, :name, :full_path

    # @replicator [Gitlab::Geo::Replicator] Gitlab Geo Replicator
    # @params [Hash] Should include keys: full_path, repository_storage, disk_path
    def initialize(replicator, params = {})
      @replicator = replicator
      @params = params
      @full_path = params[:full_path]
      @id = replicator.model_record_id
    end

    def execute
      destroy_repository
      destroy_registry if registry
    end

    private

    def destroy_repository
      # We don't have repository location information after main DB record deletion.
      # The issue https://gitlab.com/gitlab-org/gitlab/-/issues/281430
      return unless full_path

      repository = Repository.new(params[:disk_path], self, shard: params[:repository_storage])
      result = Repositories::DestroyService.new(repository).execute

      if result[:status] == :success
        log_info('Repository removed', params)
      else
        log_error("#{replicable_name} couldn't be destroyed", nil, params)
      end
    end

    def destroy_registry
      registry.destroy

      log_info('Registry removed', params)
    end

    def registry
      replicator.registry
    end
  end
end
