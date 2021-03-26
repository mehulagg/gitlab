# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module CiCd
        class Menu < ::Sidebars::Menu
          override :configure_menu_items
          def configure_menu_items
            add_item(MenuItems::Pipelines.new(context))
            add_item(MenuItems::PipelineEditor.new(context))
            add_item(MenuItems::Jobs.new(context))
            add_item(MenuItems::Artifacts.new(context))
            add_item(MenuItems::PipelineSchedules.new(context))
          end

          override :menu_link
          def menu_link
            project_pipelines_path(context.project)
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'shortcuts-pipelines qa-link-pipelines rspec-link-pipelines',
              data: { qa_selector: 'ci_cd_link' }
            }
          end

          override :menu_name
          def menu_name
            _('CI/CD')
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              id: 'js-onboarding-pipelines-link'
            }
          end

          override :sprite_icon
          def sprite_icon
            'rocket'
          end

          override :render?
          def render?
            can?(context.current_user, :read_build, context.project)
          end
        end
      end
    end
  end
end

Sidebars::Projects::Menus::CiCd::Menu.prepend_if_ee('EE::Sidebars::Projects::Menus::CiCd::Menu')
