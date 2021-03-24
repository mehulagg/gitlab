# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      class LearnGitlabMenu < ::Sidebar::Menu
        include LearnGitlabHelper

        override :link_to_href
        def link_to_href
          project_learn_gitlab_path(context.project)
        end

        override :nav_link_params
        def nav_link_params
          { controller: :learn_gitlab }
        end

        override :menu_name
        def menu_name
          _('Learn GitLab')
        end

        override :sprite_icon
        def sprite_icon
          'home'
        end

        override :render?
        def render?
          learn_gitlab_experiment_enabled?(context.project)
        end
      end
    end
  end
end
