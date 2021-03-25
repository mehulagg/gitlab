# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module CiCd
        module MenuItems
          class PipelineEditor < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_ci_pipeline_editor_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name
              }
            end

            override :nav_link_params
            def nav_link_params
              { page: 'projects/ci/pipeline_editor#show' }
            end

            override :item_name
            def item_name
              s_('Pipelines|Editor')
            end

            override :render?
            def render?
              context.can_view_pipeline_editor
            end
          end
        end
      end
    end
  end
end
