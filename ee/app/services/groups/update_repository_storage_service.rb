# frozen_string_literal: true

module Groups
  class UpdateRepositoryStorageService
    include UpdateRepositoryStorageMethods

    delegate :group, to: :repository_storage_move

    private

    def track_repository(destination_storage_name)
      if group.wiki_repository_exists?
        group.wiki.track_wiki_repository(destination_storage_name)
      end
    end

    def mirror_repositories
      if group.wiki_repository_exists?
        mirror_repository(type: Gitlab::GlRepository::WIKI)
      end
    end

    def remove_old_paths
      if group.wiki_repository_exists?
        Gitlab::Git::Repository.new(
          source_storage_name,
          "#{group.wiki.disk_path}.git",
          nil,
          nil
        ).remove
      end
    end
  end
end
