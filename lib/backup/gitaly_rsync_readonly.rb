module Backup
  class GitalyRsyncReadonly
    BACKUP_MAPPING = {
      default: {
        source_path: "/var/opt/gitlab/git-data/repositories",
        destination_path: "/tmp/backup-default/repositories"
      }
    }.freeze

    attr_accessor :progress

    def initialize(progress)
      @progress = progress
    end

    def execute
      # sanity checks, so that we can safely go through fork networks one by one marking as readonly
      if Project.count != projects_outside_fork_networks.count + ForkNetworkMember.distinct(:project_id).count
        progress.puts "FAIL: possible data inconsistency in the database"
        return
      end

      unless Gitlab.config.repositories.storages.keys.map(&:to_sym).sort == BACKUP_MAPPING.keys.sort
        progress.puts "FAIL: there needs to be a mapping for each git shard configured"
        return
      end

      BACKUP_MAPPING.values.each do |backup_map|
        unless Dir.exist?(backup_map[:source_path])
          progress.puts "FAIL: directory #{backup_map[:source_path]} doesn't exist"
          return
        end
        FileUtils.mkdir_p(backup_map[:destination_path])
      end

      backup_repositories_without_git_alternates
      backup_repositories_in_fork_networks
    end

    def backup_repositories_without_git_alternates
      # snippets are not deduplicated
      Snippet.find_each do |snippet|
        backup_repository(snippet, type: Gitlab::GlRepository::SNIPPET)
      end

      projects_outside_fork_networks.find_each do |project|
        backup_repository(project, type: Gitlab::GlRepository::PROJECT)
        backup_repository(project, type: Gitlab::GlRepository::WIKI)
        backup_repository(project, type: Gitlab::GlRepository::DESIGN)
      end
    end

    def backup_repositories_in_fork_networks
      ForkNetwork.find_each do |fork_network|
        # make all projects within the fork network read-only to prevent
        # concurrent access that might cause data inconsistency issues
        toggle_write_access_for_projects_in_fork_network(fork_network, write_access: false)

        backup_pool_repository_for_fork(fork_network)
        fork_network.projects.find_each do |project|
          backup_repository(project, type: Gitlab::GlRepository::PROJECT)
          # wikis and designs aren't deduplicated however
          # it's simpler to backup them here as well
          backup_repository(project, type: Gitlab::GlRepository::WIKI)
          backup_repository(project, type: Gitlab::GlRepository::DESIGN)
        end
      ensure
        toggle_write_access_for_projects_in_fork_network(fork_network, write_access: true)
      end
    end

    private

    def toggle_write_access_for_projects_in_fork_network(fork_network, write_access: false)
      fork_network.projects.find_each do |project|
        progress.puts "Toggling write access to #{write_access} for project ##{project.id}"

        if write_access
          project.set_repository_writable!
        else
          project.set_repository_read_only!(skip_git_transfer_check: true)
        end
      rescue StandardError => e
        progress.puts "[Failed] Toggling write access to #{write_access} for project ##{project.id}"
        progress.puts "Error #{e}"
      end
    end

    def copy_repository(source_path, dest_path, repository_path)
      # rsync specific copy strategy
      # rsync --delete --checksum -aR source/path/./1/2/3 dest/path/ generates the path relative to `./`
      # i.e. rsyncs to dest/path/1/2/3
      source_path = File.join(source_path.gsub(%r{/+$}, ''), ".", repository_path)
      dest_path = dest_path.gsub(%r{/+$}, '')

      # note the difference between using repository.empty?
      # we also create git directories (even if empty)
      # restoring might throw an exception when accessed afterwards
      unless Dir.exist?(source_path)
        progress.puts " * #{repository_path} ... " + "[EMPTY] [SKIPPED]"
        return
      end

      cmd = [%w[rsync -aR --delete --checksum], %W[#{source_path} #{dest_path}/]].flatten
      output, status = Gitlab::Popen.popen(cmd)

      # Retry if rsync source files vanish
      if status == 24
        progress.puts "Warning: files vanished during rsync, retrying..."
        output, status = Gitlab::Popen.popen(cmd)
      end

      unless status == 0
        progress.puts output
        raise Backup::Error, 'Backup failed'
      end
    end

    def backup_repository(container, type:)
      repository = type.repository_for(container)
      progress.puts " * #{repository.relative_path} ... "

      backup_path_data = BACKUP_MAPPING[repository.shard.to_sym]
      copy_repository(backup_path_data[:source_path], backup_path_data[:destination_path], repository.relative_path)
    rescue StandardError => e
      progress.puts "[Failed] backing up repository of type #{type.name} with ID #{container.id}: #{e}"
      progress.puts e.backtrace[..5]
    end

    def backup_pool_repository_for_fork(fork_network)
      project = fork_network.root_project || fork_network.projects.where.not(pool_repository_id: nil).first

      unless project.present? && project.pool_repository.present?
        # there are cases where pool repositories don't exist for fork networks
        # - we did not backfill deduplication, so fork networks created pre ~12.5
        # - moving projects between shards also removes pool relationships
        progress.puts "Could not find pool repository for fork network #{fork_network.id}"
        return
      end

      progress.puts " * #{project.pool_repository.disk_path} ... "
      backup_path_data = BACKUP_MAPPING[project.pool_repository.shard.name.to_sym]
      copy_repository(
        backup_path_data[:source_path],
        backup_path_data[:destination_path],
        "#{project.pool_repository.disk_path}.git"
      )
    rescue StandardError => e
      progress.puts "[Failed] backing up pool repository for fork #{fork_network.id}: #{e}"
      progress.puts e.backtrace[..5]
    end

    def projects_outside_fork_networks
      Project.includes(:route, :group, namespace: :owner)
        .left_outer_joins(:fork_network).where(fork_network_members: { project_id: nil })
    end
  end
end
