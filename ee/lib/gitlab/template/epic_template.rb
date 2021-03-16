# frozen_string_literal: true

module Gitlab
  module Template
    class EpicTemplate < BaseTemplate
      class << self
        def extension
          '.md'
        end

        def base_dir
          '.gitlab/epic_templates/'
        end

        def finder(project)
          Gitlab::Template::Finders::RepoTemplateFinder.new(project, self.base_dir, self.extension, self.categories)
        end

        def template_names(project)
          return {} unless project&.repository&.exists?

          # here we rely on project.repository caching mechanism. Ideally we would want the template finder to have its
          # own caching mechanism to avoid the back and forth call jumps between finder and model.
          #
          # follow-up issue: https://gitlab.com/gitlab-org/gitlab/-/issues/300279
          project.repository.epic_template_names_hash
        end

        def by_category(category, project = nil, empty_category_title: nil)
          super(category, project)
        end
      end
    end
  end
end
