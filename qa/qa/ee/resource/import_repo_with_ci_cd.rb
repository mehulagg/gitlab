# frozen_string_literal: true

module QA
  module EE
    module Resource
      class ImportRepoWithCICD < QA::Resource::ProjectImportedFromGithub
        def fabricate!
          super
        end

        def go_to_import_tab
          QA::Page::Project::New.perform(&:click_ci_cd_for_external_repo)
        end
      end
    end
  end
end
