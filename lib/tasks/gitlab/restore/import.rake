# frozen_string_literal: true

# Restore a group with all its subgroups and projects.
#
# Parameters
#   - username: User used to do the import
#   - path of the file: path to the .tar.gz file
#   - group full path: Full path of the root group
#   - import type: what should be imported. Valid options are `all`, `group`, and `project`
#
# @example
#   bundle exec rake "gitlab:restore:import[root, /path/to/file.tar.gz, foo/bar/xpto, all]"
namespace :gitlab do
  namespace :restore do
    desc <<~EOM
    GitLab | EXPERIMENTAL | Import full group tree with projects
    Files must be exported with "rake gitlab:restore:import"'
    EOM
    task :import, [:username, :export_file, :group_path, :import_type] => :gitlab_environment do |_t, args|
      # Load it here to avoid polluting Rake tasks with Sidekiq test warnings
      require 'sidekiq/testing'

      logger = Logger.new($stdout)

      begin
        warn_user_is_not_gitlab

        if ENV['RESTORE_DEBUG'].present?
          Gitlab::Utils::Measuring.logger = logger
          ActiveRecord::Base.logger = logger
          logger.level = Logger::DEBUG
        else
          logger.level = Logger::INFO
        end

        Gitlab::Restore::ImportTask.new(
          username: args.username,
          export_file: args.export_file,
          group_path: args.group_path,
          import_type: args.import_type,
          logger: logger
        ).execute

        exit
      rescue StandardError => e
        logger.error "Exception: #{e.message}"
        logger.debug "---\n#{e.backtrace.join("\n")}"
        exit 1
      end
    end
  end
end
