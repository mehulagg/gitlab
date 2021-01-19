# frozen_string_literal: true

module Wikis
  class GitGarbageCollectWorker # rubocop:disable Scalability/IdempotentWorker
    extend ::Gitlab::Utils::Override
    include GitGarbageCollectMethods

    private

    override :find_resource
    def find_resource(id)
      Project.find(id).wiki
    end

    override :update_repository_statistics
    def update_repository_statistics(resource)
      super

      Projects::UpdateStatisticsService.new(resource, nil, statistics: [:wiki_size]).execute
    end
  end
end
