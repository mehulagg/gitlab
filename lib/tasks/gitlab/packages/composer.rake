# frozen_string_literal: true

require 'logger'

desc "GitLab | Packages | Build composer cache"
namespace :gitlab do
  namespace :packages do
    task build_composer_cache: :environment do
      logger = Logger.new(STDOUT)
      logger.info('Starting to build composer cache files')

      ::Packages::Package.composer.grouped_by_project_and_name.find_in_batches do |packages|
        packages.group_by { |pkg| [pkg.project_id, pkg.name] }.keys.each do |(project_id, name)|
        end
      end
    end
  end
end
