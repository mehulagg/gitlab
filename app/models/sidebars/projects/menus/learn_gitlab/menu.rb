# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module LearnGitlab
        class Menu < ::Sidebars::Menu
          include LearnGitlabHelper

          override :menu_link
          def menu_link
            project_learn_gitlab_path(context.project)
          end

          override :active_routes
          def active_routes
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
end
