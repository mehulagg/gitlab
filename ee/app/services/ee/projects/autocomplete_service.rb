# frozen_string_literal: true
module EE
  module Projects
    module AutocompleteService
      def epics
        EpicsFinder
          .new(current_user, group_id: project.group&.id, state: 'opened')
          .execute.select([:iid, :title])
      end
    end
  end
end
