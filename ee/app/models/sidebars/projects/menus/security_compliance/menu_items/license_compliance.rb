# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class LicenseCompliance < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_licenses_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name,
                data: { qa_selector: 'licenses_list_link' }
              }
            end

            override :nav_link_params
            def nav_link_params
              { path: 'projects/licenses#index' }
            end

            override :item_name
            def item_name
              _('License Compliance')
            end

            override :render?
            def render?
              can?(context.current_user, :read_licenses, context.project)
            end
          end
        end
      end
    end
  end
end
