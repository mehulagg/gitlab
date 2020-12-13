# frozen_string_literal: true

module Gitlab
  module Composer
    class Cache
      def update(package)
        package.composer_metadatum.update(version_cache_sha: versions_json(package).sha)
      end

      private

      def versions_json(package)
        ::Gitlab::Composer::VersionJson.new(sibling_packages(package))
      end

      def sibling_packages(package)
        package.project.packages.with_name(package.name)
      end
    end
  end
end
