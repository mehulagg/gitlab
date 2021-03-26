# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module Analytics
          module Menu
            extend ::Gitlab::Utils::Override

            override :configure_menu_items
            def configure_menu_items
              super

              add_item(::Sidebars::Projects::Menus::Analytics::MenuItems::Insights.new(context))
              add_item(::Sidebars::Projects::Menus::Analytics::MenuItems::CodeReview.new(context))
              add_item(::Sidebars::Projects::Menus::Analytics::MenuItems::Issue.new(context))
              add_item(::Sidebars::Projects::Menus::Analytics::MenuItems::MergeRequest.new(context))
            end
          end
        end
      end
    end
  end
end
