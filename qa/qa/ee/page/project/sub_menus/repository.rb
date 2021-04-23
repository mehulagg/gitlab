# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module SubMenus
          module Repository
            extend QA::Page::PageConcern

            def self.prepended(base)
              base.class_eval do
                view 'app/views/shared/nav/_sidebar_menu_item.html.haml' do
                  element :sidebar_menu_item_link
                end
              end
            end

            def go_to_repository_locked_files
              hover_repository do
                within_submenu do
                  click_element(:sidebar_menu_item_link, menu_item: 'Locked Files')
                end
              end
            end
          end
        end
      end
    end
  end
end
