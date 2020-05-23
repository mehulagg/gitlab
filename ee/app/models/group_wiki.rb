# frozen_string_literal: true

class GroupWiki < Wiki
  alias_method :group, :container

  override :create_wiki_repository
  def create_wiki_repository
    super

    storage_record = container.group_wiki_repository || container.build_group_wiki_repository
    storage_record.update!(shard_name: repository_storage, disk_path: storage.disk_path)
  end

  override :storage
  def storage
    @storage ||= Storage::Hashed.new(container, prefix: Storage::Hashed::GROUP_REPOSITORY_PATH_PREFIX)
  end

  override :repository_storage
  def repository_storage
    container.group_wiki_repository&.shard_name || self.class.pick_repository_storage
  end

  override :hashed_storage?
  def hashed_storage?
    true
  end

  override :disk_path
  def disk_path(*args, &block)
    storage.disk_path + '.wiki'
  end
end
