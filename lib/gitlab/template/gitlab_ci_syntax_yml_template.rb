# frozen_string_literal: true

module Gitlab
  module Template
    class GitlabCiSyntaxYmlTemplate < BaseTemplate
      BASE_EXCLUDED_PATTERNS = [%r{\.latest\.}].freeze

      class << self
        include Gitlab::Utils::StrongMemoize

        def extension
          '.gitlab-ci.yml'
        end

        def categories
          {
            'keywords' => ''
          }
        end

        def base_dir
          Rails.root.join('lib/gitlab/ci/syntax_templates')
        end

        def finder(project = nil)
          Gitlab::Template::Finders::GlobalTemplateFinder.new(
            self.base_dir, self.extension, self.categories
          )
        end
      end
    end
  end
end

Gitlab::Template::GitlabCiYmlTemplate.prepend_if_ee('::EE::Gitlab::Template::GitlabCiYmlTemplate')
