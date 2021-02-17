# frozen_string_literal: true

class GroupWiki < Wiki
  self.container_class = ::Group
  alias_method :group, :container

  override :create_wiki_repository
  def create_wiki_repository
    super

    track_wiki_repository(repository.shard)
  end

  def track_wiki_repository(shard)
    storage_record = container.group_wiki_repository || container.build_group_wiki_repository
    storage_record.update!(shard_name: shard, disk_path: storage.disk_path)
  end

  override :storage
  def storage
    @storage ||= Storage::Hashed.new(container, prefix: Storage::Hashed::GROUP_REPOSITORY_PATH_PREFIX)
  end

  override :repository_storage
  def repository_storage
    container.repository_storage
  end

  override :hashed_storage?
  def hashed_storage?
    true
  end

  override :disk_path
  def disk_path(*args, &block)
    storage.disk_path + '.wiki'
  end

  override :after_wiki_activity
  def after_wiki_activity
    # TODO: Check if we need to update any columns for Geo replication,
    # like we do in ProjectWiki#after_wiki_activity
    # https://gitlab.com/gitlab-org/gitlab/-/issues/208147
  end

  override :after_post_receive
  def after_post_receive
    # Update group wiki storage statistics directly. At the moment, since groups
    # can only have one type of repository, and it's not a very demanding one
    # we can update the statistics in the same thread. Projects do this
    # in the ProjectCacheWorker because it can be a more stressing environment
    # because several updates can trigger the same statistics update.
    Groups::UpdateStatisticsService.new(group).execute # rubocop:disable CodeReuse/ServiceClass
  end

  override :git_garbage_collect_worker_klass
  def git_garbage_collect_worker_klass
    GroupWikis::GitGarbageCollectWorker
  end
end
