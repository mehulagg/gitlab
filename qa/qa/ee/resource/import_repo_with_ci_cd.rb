# frozen_string_literal: true

module QA
  module EE
    module Resource
      class ImportRepoWithCiCd < QA::Resource::ProjectImportedFromGithub
        def go_to_import_page
          # Overriding CE go_to_import_page, the differences happen in BE when CI/CD option is selected vs Import option
          QA::Page::Project::New.perform do |project_page|
            project_page.click_cicd_for_external_repo
            project_page.click_github_link
          end
        end
      end
    end
  end
end
