# frozen_string_literal: true

# @example
#
#   bundle exec rake "gitlab:import_export:export[root, g1, /path/to/file.tar.gz]" # will include repos
namespace :gitlab do
  namespace :restore do
    desc 'GitLab | Import/Export | EXPERIMENTAL | Export large project archives'
    task :export, [:username, :group_path, :export_path, :page_size] => :gitlab_environment do |_t, args|
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

        top_level_group = Group.find_by_full_path(args.group_path)
        groups = Gitlab::ObjectHierarchy.new(Group.where(id: top_level_group.id)).base_and_descendants
        project_count = Project.where(group: groups).size

        page_size = Integer(args.page_size)

        number_pages = (project_count/page_size.to_f).ceil

        number_pages.times do |page|
          Gitlab::Restore::ExportTask.new(
            group_path: args.group_path,
            username: args.username,
            export_path: args.export_path,
            logger: logger,
            page: page,
            page_size: page_size
          ).execute
        end

        exit
      rescue StandardError => e
        logger.error "Exception: #{e.message}"
        logger.debug "---\n#{e.backtrace.join("\n")}"
        exit 1
      end
    end
  end
end
