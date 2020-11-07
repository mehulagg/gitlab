require 'logger'

desc "GitLab | Packages | Events | Generate hll counter events file for packages"
namespace :gitlab do
  namespace :packages do
    namespace :events do
      task generate: :environment do
        logger = Logger.new(STDOUT)
        logger.info('Starting transfer of package files to object storage')
        rescue => e
        end
      end
    end
  end
end
