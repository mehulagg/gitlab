# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module SubMenus
          module Settings
            extend QA::Page::PageConcern

            def self.prepended(base)
              base.class_eval do
                prepend QA::Page::Project::SubMenus::Common
              end
            end

            private

            def hover_settings
              within_sidebar do
                scroll_to_element(:settings_item)
                find_element(:settings_item).hover

                yield
              end
            end
          end
        end
      end
    end
  end
end
