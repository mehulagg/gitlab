# frozen_string_literal: true

namespace :gitlab do
  namespace :seed do
    namespace :insights do
      desc "GitLab | Seed | Insights | Seeds issues for Insights charts"
      task :issues, [:project_full_path] => :environment do |t, args|
        projects =
          if args.project_full_path
            project = Project.find_by_full_path(args.project_full_path)

            unless project
              error_message = "Project '#{args.project_full_path}' does not exist!"
              potential_projects = Project.search(args.project_full_path)

              if potential_projects.present?
                error_message += " Did you mean '#{potential_projects.first.full_path}'?"
              end

              puts error_message.color(:red)
              exit 1
            end

            [project]
          else
            Project.find_each
          end

        projects.each do |project|
          puts "\nSeeding issues for the Insights charts of the '#{project.full_path}' project"
          seeder = Quality::Seeders::Insights::Issues.new(project: project)
          issues_created = seeder.seed
          puts "\n#{issues_created} issues created!"
        end
      end
    end
  end
end
