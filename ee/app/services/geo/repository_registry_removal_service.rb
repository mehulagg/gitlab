# frozen_string_literal: true

module Geo
  class RepositoryRegistryRemovalService
    include ::Gitlab::Utils::StrongMemoize
    include ::Gitlab::Geo::LogHelpers

    attr_reader :params

    def initialize(params)
      @params = params
    end

    def execute
      destroy_repository
      destroy_registry if registry
    end

    private

    def destroy_repository
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

    def replicator
      strong_memoize(:replicator) do
        Gitlab::Geo::Replicator.for_replicable_params(
          replicable_name: params[:replicable_name],
          replicable_id: params[:model_record_id]
        )
      end
    end
  end
end
