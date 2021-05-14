# frozen_string_literal: true

# These helpers help you interact within the Editor Lite (single-file editor, snippets, etc.).
#
module Spec
  module Support
    module Helpers
      module Features
        module TopNavSpecHelpers
          def open_top_nav
            find('.js-top-nav-dropdown-toggle').click if Feature.enabled?(:combined_menu)
          end
        end
      end
    end
  end
end
