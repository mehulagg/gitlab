# frozen_string_literal: true

module Gitlab
  module Composer
    class Cache
      def initialize(package)
        @package = package
      end

      def update
        Packages::Composer::Metadatum.lock("FOR UPDATE SKIP LOCKED") do # rubocop: disable CodeReuse/ActiveRecord
          #new_sha = versions_index.sha
          # siblings.select { |pkg| pkg.composer_metadatum}
          #byebug

          #Packages::Composer::Metadatum.where(package_id: siblings.map(&:id)).update(version_cache_sha: new_sha)
        end
      end

      private

      def versions_index
        @versions_index ||= ::Gitlab::Composer::VersionIndex.new(siblings)
      end

      def siblings
        @package.project.packages.with_name(@package.name).order_updated_desc
      end
    end
  end
end
