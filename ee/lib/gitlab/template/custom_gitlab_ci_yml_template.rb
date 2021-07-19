# frozen_string_literal: true

module Gitlab
  module Template
    class CustomGitlabCiYmlTemplate < CustomTemplate
      include Gitlab::Utils::StrongMemoize

      def has_metadata?
        parsed_yaml.has_key?(:template_metadata)
      end

      def metadata
        return unless has_metadata?

        @metadata ||= Gitlab::Ci::Config::Entry::TemplateMetadata.new(parsed_yaml[:template_metadata])
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
        def extension
          '.yml'
        end

        def base_dir
          'gitlab-ci/'
        end
      end
    end
  end
end
