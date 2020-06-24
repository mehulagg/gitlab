# frozen_string_literal: true

module Gitlab
  module StaticSiteEditor
    class Config
      SUPPORTED_EXTENSIONS = %w[.md .md.erb].freeze

      def initialize(repository, ref, file_path, return_url)
        @repository = repository
        @ref = ref
        @file_path = file_path
        @return_url = return_url
        @commit_id = repository.commit(ref)&.id if ref
      end

      def payload
        {
          branch: ref,
          path: file_path,
          commit_id: commit_id,
          project_id: project.id,
          project: project.path,
          namespace: project.namespace.path,
          return_url: sanitize_url(return_url),
          is_supported_content: supported_content?.to_s,
          base_url: Gitlab::Routing.url_helpers.project_show_sse_path(project, full_path)
        }
      end

      private

      attr_reader :repository, :ref, :file_path, :return_url, :commit_id

      delegate :project, to: :repository

      def supported_content?
        master_branch? && extension_supported? && file_exists?
      end

      def master_branch?
        ref == 'master'
      end

      def extension_supported?
        SUPPORTED_EXTENSIONS.any? { |ext| file_path.end_with?(ext) }
      end

      def file_exists?
        commit_id.present? && !repository.blob_at(commit_id, file_path).nil?
      end

      def full_path
        "#{ref}/#{file_path}"
      end

      def sanitize_url(url)
        url if Gitlab::UrlSanitizer.valid_web?(url)
      end
    end
  end
end
