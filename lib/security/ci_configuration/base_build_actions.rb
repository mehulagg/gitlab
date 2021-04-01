# frozen_string_literal: true

module Security
  module CiConfiguration
    class BaseBuildActions
      def initialize(auto_devops_enabled, params, existing_gitlab_ci_content)
        @auto_devops_enabled = auto_devops_enabled
        @existing_gitlab_ci_content = existing_gitlab_ci_content || {}
      end

      def generate
        action = @existing_gitlab_ci_content.present? ? 'update' : 'create'

        update_existing_content!

        [{ action: action, file_path: '.gitlab-ci.yml', content: prepare_existing_content, default_values_overwritten: @default_values_overwritten }]
      end

      private

      def set_includes
        includes = @existing_gitlab_ci_content['include'] || []
        includes = includes.is_a?(Array) ? includes : [includes]
        includes << { 'template' => template }
        includes.uniq
      end

      def prepare_existing_content
        content = @existing_gitlab_ci_content.to_yaml
        content = remove_document_delimeter(content)

        content.prepend(comment)
      end

      def remove_document_delimeter(content)
        content.gsub(/^---\n/, '')
      end

      def comment
        <<~YAML
          # You can override the included template(s) by including variable overrides
          # See https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings
          # See https://docs.gitlab.com/ee/user/application_security/secret_detection/#customizing-settings
          # Note that environment variables can be set in several places
          # See https://docs.gitlab.com/ee/ci/variables/#priority-of-environment-variables
        YAML
      end
    end
  end
end
