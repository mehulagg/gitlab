# frozen_string_literal: true

module Projects
  class GitGarbageCollectWorker # rubocop:disable Scalability/IdempotentWorker
    extend ::Gitlab::Utils::Override
    include GitGarbageCollectMethods

    private

    override :default_lease_key
    def default_lease_key(task, resource)
      "git_gc:#{task}:#{resource.id}"
    end

    override :find_resource
    def find_resource(id)
      Project.find(id)
    end

    override :before_gitaly_call
    def before_gitaly_call(task, resource)
      return unless gc?(task)

      ::Projects::GitDeduplicationService.new(resource).execute
      cleanup_orphan_lfs_file_references(resource)
    end

    def cleanup_orphan_lfs_file_references(resource)
      return if Gitlab::Database.read_only? # GitGarbageCollectWorker may be run on a Geo secondary

      ::Gitlab::Cleanup::OrphanLfsFileReferences.new(resource, dry_run: false, logger: logger).run!
    rescue => err
      Gitlab::GitLogger.warn(message: "Cleaning up orphan LFS objects files failed", error: err.message)
      Gitlab::ErrorTracking.track_and_raise_for_dev_exception(err)
    end

    override :update_repository_statistics
    def update_repository_statistics(resource)
      super

      return if Gitlab::Database.read_only? # GitGarbageCollectWorker may be run on a Geo secondary

      Projects::UpdateStatisticsService.new(resource, nil, statistics: [:repository_size, :lfs_objects_size]).execute
    end
  end
end
