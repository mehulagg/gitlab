# frozen_string_literal: true

module Gitlab
  module Geo
    module ProjectLogHelpers
      include LogHelpers

      def base_log_data(message)
        super.merge({
          project_id: project.try(:id),
          project_path: project.try(:full_path),
          storage_version: project.try(:storage_version)
        }).compact
      end
    end
  end
end
