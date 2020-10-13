# frozen_string_literal: true

module Security
  module Configuration
    class SaveAutoFixService
      SUPPORTED_SCANNERS = %w(container_scanning dependency_scanning all).freeze

      # @param project [Project]
      # @param ['dependency_scanning', 'container_scanning', 'all'] feature Type of scanner to apply auto_fix
      def initialize(project, feature)
        @project = project
        @feature = feature
      end

      def execute(enabled:)
        return unless valid?

        project_settings.update(toggle_params(enabled))
      end

      private

      attr_reader :enabled, :feature, :project

      def project_settings
        @project_settings ||= ProjectSecuritySetting.safe_find_or_create_for(project)
      end

      def toggle_params(enabled)
        if feature == 'all'
          {
            auto_fix_container_scanning: enabled,
            auto_fix_dast: enabled,
            auto_fix_dependency_scanning: enabled,
            auto_fix_sast: enabled
          }
        else
          {
            "auto_fix_#{feature}" => enabled
          }
        end
      end

      def valid?
        SUPPORTED_SCANNERS.include?(feature)
      end
    end
  end
end
