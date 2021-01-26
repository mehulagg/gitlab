# frozen_string_literal: true

module Gitlab
  module ImportExport
    class RepoSaver
      include Gitlab::ImportExport::CommandLineUtil

      attr_reader :exportable, :shared, :path_to_bundle

      def initialize(exportable:, shared:, path_to_bundle: nil)
        @exportable = exportable
        @shared = shared
        @path_to_bundle = path_to_bundle || default_bundle_full_path
      end

      def save
        return true unless repository_exists? # it's ok to have no repo

        bundle_to_disk
      end

      def repository
        @repository ||= @exportable.repository
      end

      private

      def repository_exists?
        repository.exists? && !repository.empty?
      end

      def default_bundle_full_path
        File.join(shared.export_path, bundle_filename)
      end

      def bundle_filename
        ::Gitlab::ImportExport.project_bundle_filename
      end

      def bundle_to_disk
        path = Pathname.new(path_to_bundle)
        mkdir_p(path.dirname)
        repository.bundle_to_disk(path.to_s)
      rescue => e
        shared.error(e)
        false
      end
    end
  end
end
