# frozen_string_literal: true

module Gitlab
  module ImportExport
    class RepoRestorer
      include Gitlab::ImportExport::CommandLineUtil

      def initialize(project:, shared:, path_to_bundle:)
        @repository = project.repository
        @path_to_bundle = path_to_bundle
        @shared = shared
      end

      def restore
        return true unless File.exist?(path_to_bundle)
        return true if repository_exists?

        repository.create_from_bundle(path_to_bundle)
      rescue => e
        shared.error(e)
        false
      end

      private

      attr_accessor :repository, :path_to_bundle, :shared

      def repository_exists?
        return false unless repository.exists?

        shared.logger.info(
          message: %Q{Repository "#{repository.path}" already exists.}
        )

        true
      end
    end
  end
end
