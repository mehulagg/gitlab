# frozen_string_literal: true

module QA
  module Page
    module SubMenus
      module Common
        def hover_element(element)
          within_sidebar do
            find_element(element).hover
            yield
          end
        end

        def within_sidebar
          wait_for_requests
          # We need to check remote_mobile_device_name instead of mobile_layout? here
          # since tablets have the regular top navigation bar but still close the left nav
          open_mobile_nav_sidebar if QA::Runtime::Env.remote_mobile_device_name

          within_element(sidebar_element) do
            yield
          end
        end

        def within_submenu(element = nil)
          if element
            within_element(element) do
              yield
            end
          else
            within_submenu_without_element do
              yield
            end
          end
        end

        private

        def within_submenu_without_element
          if has_css?('.fly-out-list')
            within('.fly-out-list') do
              yield
            end
          else
            yield
          end
        end

        def sidebar_element
          raise NotImplementedError
        end

        def open_mobile_nav_sidebar
          find('.toggle-mobile-nav').click unless has_css?('.sidebar-expanded-mobile', wait: 1)
        end
      end
    end
  end
end
