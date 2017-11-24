module EE
  # Repository EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `Repository` model
  module Repository
    extend ActiveSupport::Concern

    # Transiently sets a configuration variable
    def with_config(values = {})
      values.each { |k, v| rugged.config[k] = v }

      yield
    ensure
      values.keys.each { |key| rugged.config.delete(key) }
    end

    # Runs code after a repository has been synced.
    def after_sync
      expire_all_method_caches
      expire_branch_cache
      expire_content_cache
    end

    # Returns a list of commits that are not present in any reference
    def new_commits(newrev)
      refs = ::Gitlab::Git::RevList.new(
        path_to_repo: path_to_repo,
        newrev: newrev).new_refs

      refs.map { |sha| commit(sha.strip) }
    end

    def push_remote_branches(remote, branches)
      gitlab_shell.push_remote_branches(repository_storage_path, disk_path, remote, branches)
    end

    def delete_remote_branches(remote, branches)
      gitlab_shell.delete_remote_branches(repository_storage_path, disk_path, remote, branches)
    end
  end
end
