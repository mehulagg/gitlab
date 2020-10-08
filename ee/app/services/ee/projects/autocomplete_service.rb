# frozen_string_literal: true
module EE
  module Projects
    module AutocompleteService
      def epics
        EpicsFinder
          .new(current_user, group_id: project.group&.id, state: 'opened')
          .execute.select([:iid, :title])
      end

      def vulnerabilities
        ::Autocomplete::VulnerabilitiesAutocompleteFinder
          .new(current_user, project, params)
          .execute
          .select([:id, :title])
      end
    end
  end
end
