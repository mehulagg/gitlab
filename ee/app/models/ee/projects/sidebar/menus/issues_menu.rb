# frozen_string_literal: true

module EE
  module Projects
    module Sidebar
      module Menus
        module IssuesMenu
          extend ::Gitlab::Utils::Override

          override :initialize
          def initialize(context)
            super

            add_item(::Projects::Sidebar::Menus::Items::IterationsMenuItem.new(context))
          end
        end
      end
    end
  end
end
