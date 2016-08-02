module Page
  module Project
    class New < Page::Base
      def choose_test_namespace
        namespace = Page::Groups::TestNamespace.name

        find('#s2id_project_namespace_id').click
        find('.select2-result-label', text: namespace).click
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
