# frozen_string_literal: true

module QA
  module EE
    module Resource
      class ImportRepoWithCiCd < QA::Resource::ProjectImportedFromGithub
        def go_to_import_page
          QA::Page::Project::New.perform(&:click_cicd_for_external_repo)
        end
      end
    end
  end
end
