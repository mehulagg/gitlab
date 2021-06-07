# frozen_string_literal: true

module QA
  module Page
    module Project
      module Import
        class Gitlab < Page::Base
          include Layout::Flash

          view 'app/views/import/gitlab_projects/new.html.haml' do
            element :export_file_container
            element :import_project_button
          end

          view 'app/views/import/shared/_new_project_form.html.haml' do
            element :project_name_field
            element :project_slug_field
          end

          def enter_name(name)
            fill_element(:project_name_field, name)
          end

          def attach_file(path)
            page.attach_file("file", path, make_visible: { display: 'block' })
          end

          def click_import
            click_element(:import_project_button)

            wait_until(reload: false) do
              has_notice?("The project was successfully imported.")
            end
          end
        end
      end
    end
  end
end
