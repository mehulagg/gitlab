# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module New
          extend QA::Page::PageConcern

          def self.prepended(base)
            super

            base.class_eval do
              view 'ee/app/views/projects/_project_templates.html.haml' do
                element :group_templates_tab
                element :group_template_tab_badge
                element :instance_templates_tab
                element :instance_template_tab_badge
              end

              view 'ee/app/views/users/_custom_project_templates_from_groups.html.haml' do
                element :use_template_button
                element :template_option_row
              end

              view 'ee/app/views/users/_custom_project_templates.html.haml' do
                element :use_template_button
                element :template_option_row
              end

              view 'ee/app/views/projects/_new_ci_cd_only_project_tab.html.haml' do
                element :ci_cd_project_tab
              end
            end
          end

          def go_to_create_from_template_group_tab
            click_element(:group_templates_tab)
          end

          def go_to_create_from_template_instance_tab
            click_element(:instance_templates_tab)
          end

          def group_template_tab_badge_text
            find_element(:group_template_tab_badge).text
          end

          def instance_template_tab_badge_text
            find_element(:instance_template_tab_badge).text
          end

          def click_ci_cd_for_external_repo
            click_element :ci_cd_project_tab
          end
        end
      end
    end
  end
end
