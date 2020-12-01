# frozen_string_literal: true

module Gitlab
  module ImportExport
    class WikiRestorer < RepoRestorer
      def initialize(project:, shared:, path_to_bundle:)
        super(project: project, shared: shared, path_to_bundle: path_to_bundle)

        @project = project
      end

      private

      attr_accessor :project, :wiki_enabled

      def create_empty_wiki?
        !File.exist?(path_to_bundle) && wiki_enabled
      end
    end
  end
end
