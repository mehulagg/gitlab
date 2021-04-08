# frozen_string_literal: true

module QA
  module Page
    module Project
      module SubMenus
        module CiCd
          extend QA::Page::PageConcern

          def self.included(base)
            super

            base.class_eval do
              include QA::Page::Project::SubMenus::Common

              view 'app/views/layouts/nav/sidebar/_project.html.haml' do
                element :ci_cd_link
                element :pipeline_editor_link
              end
            end
          end

          def click_ci_cd_pipelines
            within_sidebar do
              click_element :ci_cd_link
            end
          end

          def click_pipelines_editor
            within_sidebar do
              click_element :pipeline_editor_link
            end
          end
        end
      end
    end
  end
end
