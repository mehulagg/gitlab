# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Panel
        extend ::Gitlab::Utils::Override

        override :configure_menus
        def configure_menus
          super

          insert_menu_after(::Sidebars::Projects::Menus::ExternalIssueTrackerMenu, ::Sidebars::Projects::Menus::JiraMenu.new(context))
          insert_menu_after(::Sidebars::Projects::Menus::MergeRequestsMenu, ::Sidebars::Projects::Menus::RequirementsMenu.new(context))
        end
      end
    end
  end
end
