# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module SubMenus
          module Project
            def click_project_insights_link
              hover_element(:analytics_link) do
                within_submenu(:analytics_sidebar_submenu) do
                  click_element(:project_insights_link)
                end
              end
            end
          end
        end
      end
    end
  end
end
