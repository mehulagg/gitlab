# frozen_string_literal: true

module EpicLinks
  class CreateService < IssuableLinks::CreateService
    def execute
      if issuable.max_hierarchy_depth_achieved?
        return error('Epic hierarchy level too deep', 409)
      end

      if render_epic_already_ancestor_error?
        return error('The epic to be added as child is already an ancestor', 409)
      end

      super
    end

    private

    def render_epic_already_ancestor_error?
      return false if referenced_issuables.empty?

      referenced_issuables.all? do |referenced_epic|
        referenced_epic.children.include?(issuable)
      end
    end

    def affected_epics(epics)
      [issuable, epics].flatten.uniq
    end

    def relate_issuables(referenced_epic)
      affected_epics = [issuable]
      affected_epics << referenced_epic if referenced_epic.parent

      set_child_epic!(referenced_epic)

      yield
    end

    def create_notes(referenced_epic, params)
      SystemNoteService.change_epics_relation(issuable, referenced_epic, current_user, 'relate_epic')
    end

    def set_child_epic!(child_epic)
      child_epic.parent = issuable
      child_epic.move_to_start
      child_epic.save!
    end

    def linkable_issuables(epics)
      @linkable_issuables ||= begin
        return [] unless can?(current_user, :admin_epic, issuable.group)

        epics.select do |epic|
          linkable_epic?(epic)
        end
      end
    end

    def linkable_epic?(epic)
      epic.valid_parent?(
        parent_epic: issuable,
        parent_group_descendants: issuable_group_descendants
      )
    end

    def references(extractor)
      extractor.epics
    end

    def extractor_context
      { group: issuable.group }
    end

    def previous_related_issuables
      issuable.children.to_a
    end

    def issuable_group_descendants
      @descendants ||= issuable.group.self_and_descendants
    end

    def issuables_assigned_message
      'Epic(s) already assigned'
    end

    def issuables_not_found_message
      'No Epic found for given params'
    end
  end
end
