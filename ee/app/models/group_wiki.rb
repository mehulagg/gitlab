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
    # Update group wiki storage statistics
    Groups::UpdateStatisticsWorker.perform_async(group.id, [:wiki_size])
  end

  override :after_post_receive
  def after_post_receive
    # TODO: Update group wiki storage
    # https://gitlab.com/gitlab-org/gitlab/-/issues/230465
  end

  override :git_garbage_collect_worker_klass
  def git_garbage_collect_worker_klass
    GroupWikis::GitGarbageCollectWorker
  end
end
