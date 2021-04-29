# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module SubMenus
          module Project
            def click_project_insights_link
              hover_element(:sidebar_menu_link, menu_item: 'Analytics') do
                within_submenu do
                  click_element(:sidebar_menu_item_link, menu_item: 'Insights')
                end
              end
            end
          end
        end
      end
    end
  end
end
