# frozen_string_literal: true

module Gitlab
  module Template
    class GitlabCiYmlTemplate < BaseTemplate
      include Gitlab::Utils::StrongMemoize

      BASE_EXCLUDED_PATTERNS = [%r{\.latest\.}].freeze

      TEMPLATES_WITH_LATEST_VERSION = {
        'Jobs/Browser-Performance-Testing' => true,
        'Security/API-Fuzzing' => true,
        'Security/DAST' => true,
        'Terraform' => true
      }.freeze

      def description
        "# This file is a template, and might need editing before it works on your project."
      end

      def has_metadata?
        parsed_yaml.has_key?(:template_metadata)
      end

      def metadata
        return unless has_metadata?

        @metadata ||= Gitlab::Ci::Config::Entry::TemplateMetadata.new(parsed_yaml[:template_metadata])
      end

      def path
        full_name
      end

      private

      def parsed_yaml
        strong_memoize(:parsed_yaml) do
          Gitlab::Ci::Config::Yaml.load!(content)
        rescue Gitlab::Config::Loader::FormatError
          {}
        end
      end

      class << self
        extend ::Gitlab::Utils::Override
        include Gitlab::Utils::StrongMemoize

        def extension
          '.gitlab-ci.yml'
        end

        def categories
          {
            'General' => '',
            'Pages' => 'Pages',
            'Verify' => 'Verify',
            'Auto deploy' => 'autodeploy'
          }
        end

        def include_categories_for_file
          {
            "SAST#{self.extension}" => { 'Security' => 'Security' }
          }
        end

        def excluded_patterns
          strong_memoize(:excluded_patterns) do
            BASE_EXCLUDED_PATTERNS + additional_excluded_patterns
          end
        end

        def additional_excluded_patterns
          [%r{Verify/Browser-Performance}]
        end

        def base_dir
          Rails.root.join('lib/gitlab/ci/templates')
        end

        def finder(project = nil)
          Gitlab::Template::Finders::GlobalTemplateFinder.new(
            self.base_dir,
            self.extension,
            self.categories,
            self.include_categories_for_file,
            excluded_patterns: self.excluded_patterns
          )
        end

        override :find
        def find(key, project = nil)
          if try_redirect_to_latest?(key, project)
            key += '.latest'
          end

          super(key, project)
        end

        override :all
        def all(project = nil, filtering_options = {})
          templates = super(project)
          filtering_by_metadata(filtering_options, templates)
        end

        private

        def filtering_by_metadata(filtering_options, templates)
          return templates unless filtering_options[:metadata].present?

          # Filtering by metadata
          templates.select do |template|
            next false unless template.has_metadata?

            template.metadata.match?(filtering_options[:metadata])
          end
        end

        # To gauge the impact of the latest template,
        # you can redirect the stable template to the latest template by enabling the feature flag.
        # See https://docs.gitlab.com/ee/development/cicd/templates.html#versioning for more information.
        def try_redirect_to_latest?(key, project)
          return false unless templates_with_latest_version[key]

          flag_name = "redirect_to_latest_template_#{key.underscore.tr('/', '_')}"
          ::Feature.enabled?(flag_name, project, default_enabled: :yaml)
        end

        def templates_with_latest_version
          TEMPLATES_WITH_LATEST_VERSION
        end
      end
    end
  end
end

Gitlab::Template::GitlabCiYmlTemplate.prepend_mod
