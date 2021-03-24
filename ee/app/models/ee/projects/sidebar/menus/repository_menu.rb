# frozen_string_literal: true

module EE
  module Projects
    module Sidebar
      module Menus
        module RepositoryMenu
          extend ::Gitlab::Utils::Override

          override :initialize
          def initialize(context)
            super

            add_item(::Projects::Sidebar::Menus::Items::FileLocksMenuItem.new(context))
          end
        end
      end
    end
  end
end
