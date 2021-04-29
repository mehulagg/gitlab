# frozen_string_literal: true

module Gitlab
  module Migrations
    class ArtifactHelper < BaseHelper
      private

      def items_stored_locally
        ::Ci::JobArtifact.with_files_stored_locally
      end

      def items_stored_remotely
        ::Ci::JobArtifact.with_files_stored_remotely
      end
    end
  end
end
