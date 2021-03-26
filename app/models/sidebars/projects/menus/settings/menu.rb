# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Settings
        class Menu < ::Sidebars::Menu
          override :configure_menu_items
          def configure_menu_items
            add_item(MenuItems::General.new(context))
            add_item(MenuItems::Integrations.new(context))
            add_item(MenuItems::WebHooks.new(context))
            add_item(MenuItems::AccessTokens.new(context))
            add_item(MenuItems::Repository.new(context))
            add_item(MenuItems::CiCd.new(context))
            add_item(MenuItems::Operations.new(context))
            add_item(MenuItems::Pages.new(context))
          end

          override :menu_link
          def menu_link
            edit_project_path(context.project)
          end

          override :menu_name
          def menu_name
            _('Settings')
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              id: 'js-onboarding-settings-link'
            }
          end

          override :sprite_icon
          def sprite_icon
            'settings'
          end

          override :render?
          def render?
            can?(context.current_user, :admin_project, context.project)
          end
        end
      end
    end
  end
end
