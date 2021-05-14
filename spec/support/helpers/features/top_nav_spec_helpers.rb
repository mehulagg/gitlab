# frozen_string_literal: true

# These helpers help you interact within the Editor Lite (single-file editor, snippets, etc.).
#
module Spec
  module Support
    module Helpers
      module Features
        module TopNavSpecHelpers
          def open_top_nav
            return unless Feature.enabled?(:combined_menu)

            find('.js-top-nav-dropdown-toggle').click
          end

          def within_top_nav
            open_top_nav

            within('.js-top-nav-dropdown-menu') do
              yield
            end
          end

          def open_top_nav_projects
            return unless Feature.enabled?(:combined_menu)

            within_top_nav do
              click_button('Projects')
            end
          end

          def open_top_nav_groups
            return unless Feature.enabled?(:combined_menu)

            within_top_nav do
              click_button('Groups')
            end
          end
        end
      end
    end
  end
end
