# frozen_string_literal: true

module Gitlab
  module Geo
    module ContainerRepositoryLogHelpers
      include LogHelpers

      # This is called by LogHelpers to build json log with context info
      #
      # @see ::Gitlab::Geo::LogHelpers
      def extra_log_data
        {
          project_id: container_repository.project.id,
          project_path: container_repository.project.full_path,
          container_repository_name: container_repository.name
        }.compact
      end
    end
  end
end
