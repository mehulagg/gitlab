module QA
  module Page
    module Project
      class New < Page::Base
        def choose_test_namespace
          find('#s2id_project_namespace_id').click
          find('.select2-result-label', text: Test::Namespace.name).click
        end

        def choose_name(name)
          fill_in 'project_path', with: name
        end

        def add_description(description)
          fill_in 'project_description', with: description
        end

        def create_new_project
          click_on 'Create project'
        end
      end
    end
  end
end
