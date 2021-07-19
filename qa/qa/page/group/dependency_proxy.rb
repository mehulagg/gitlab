
# frozen_string_literal: true

module QA
  module Page
    module Group
      class DependencyProxy < QA::Page::Base
        view 'app/views/groups/dependency_proxies/show.html.haml' do
          element :dependency_proxy_setting_toggle
        end

        def has_dependency_proxy_enabled?
          toggle = find_element(:dependency_proxy_setting_toggle)
          toggle[:class].include?('is-checked')
        end
      end
    end
  end
end
  