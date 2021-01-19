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

      return if Gitlab::Database.read_only? # GitGarbageCollectWorker may be run on a Geo secondary

      Projects::UpdateStatisticsService.new(resource, nil, statistics: [:wiki_size]).execute
    end
  end
end
